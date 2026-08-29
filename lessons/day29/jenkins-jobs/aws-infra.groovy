pipeline {
    agent any

    parameters {
        string(name: 'GIT_REPO', defaultValue: 'https://github.com/your-org/your-repo.git')
        string(name: 'GIT_BRANCH', defaultValue: 'main')
        choice(
            name: 'ACTION', 
            choices: [
                'Apply-All', 
                'Apply-VPC-Only', 
                'Apply-EKS-Only',
                'Plan', 
                'Destroy-EKS-Only', 
                'Destroy-VPC-Only', 
                'Destroy-All'
            ]
        )
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Install CLI Tools') {
            steps {
                sh '''
                    set -e

                    export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

                    echo '--- Checking for required CLIs ---'

                    if ! command -v aws >/dev/null 2>&1; then
                        echo 'AWS CLI not found. Installing...'

                        if command -v sudo >/dev/null 2>&1; then
                            sudo apt-get update
                            sudo apt-get install -y awscli curl unzip
                        elif [ "$(id -u)" -eq 0 ]; then
                            apt-get update
                            apt-get install -y awscli curl unzip
                        else
                            python3 -m pip install --user awscli
                        fi
                    fi

                    if ! command -v kubectl >/dev/null 2>&1; then
                        echo 'kubectl not found. Installing...'
                        curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                        chmod +x kubectl

                        if [ "$(id -u)" -eq 0 ] || command -v sudo >/dev/null 2>&1; then
                            install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                        else
                            mkdir -p "$HOME/bin"
                            install -m 0755 kubectl "$HOME/bin/kubectl"
                        fi
                    fi

                    export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
                    echo "AWS CLI: $(aws --version)"
                    echo "kubectl: $(kubectl version --client --output=yaml | head -n 10)"
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                git url: "${params.GIT_REPO}", branch: "${params.GIT_BRANCH}"
            }
        }

        stage('Terraform Execution') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials-id',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir('lessons/day29/terraform') {
                        script {
                            sh 'terraform init -input=false'

                            if (params.ACTION == 'Apply-VPC-Only') {
                                echo '--- Provisioning VPC Module Only ---'
                                sh 'terraform apply -target=module.vpc -input=false -auto-approve'

                            } else if (params.ACTION == 'Apply-EKS-Only') {
                                echo '--- Provisioning EKS Module Only ---'
                                sh 'terraform apply -target=module.eks -input=false -auto-approve'

                            } else if (params.ACTION == 'Apply-All') {
                                echo '--- Step 1: Guaranteeing VPC Subnets Exist ---'
                                sh 'terraform apply -target=module.vpc -input=false -auto-approve'

                                echo '--- Step 2: Provisioning EKS Cluster & Remaining Resources ---'
                                sh 'terraform plan -input=false -out=tfplan'
                                sh 'terraform apply -input=false tfplan'

                            } else if (params.ACTION == 'Destroy-EKS-Only') {
                                echo '--- Destroying EKS Module Only ---'
                                sh 'terraform destroy -target=module.eks -input=false -auto-approve'

                            } else if (params.ACTION == 'Destroy-VPC-Only') {
                                echo '--- Safety Check: Verifying EKS state in AWS ---'
                                
                                def clusterStatus = sh(
                                    script: "aws eks describe-cluster --name gitops-eks-cluster --region us-east-1 --query 'cluster.status' --output text 2>/dev/null || echo 'NOT_FOUND'",
                                    returnStdout: true
                                ).trim()

                                if (clusterStatus != 'NOT_FOUND') {
                                    error("ABORTING: EKS Cluster 'gitops-eks-cluster' currently exists (Status: ${clusterStatus}). You must run 'Destroy-EKS-Only' or 'Destroy-All' first!")
                                }

                                echo '--- No active EKS cluster found. Safe to destroy VPC ---'
                                sh 'terraform destroy -target=module.vpc -input=false -auto-approve'

                            } else if (params.ACTION == 'Destroy-All') {
                                echo '--- Safety Check: Verifying EKS state before destroying ---'
                                
                                def clusterStatus = sh(
                                    script: "aws eks describe-cluster --name gitops-eks-cluster --region us-east-1 --query 'cluster.status' --output text 2>/dev/null || echo 'NOT_FOUND'",
                                    returnStdout: true
                                ).trim()

                                if (clusterStatus != 'NOT_FOUND') {
                                    echo "--- Active EKS cluster detected (Status: ${clusterStatus}). Destroying EKS first... ---"
                                    sh 'terraform destroy -target=module.eks -input=false -auto-approve'
                                } else {
                                    echo '--- No active EKS cluster found. Skipping EKS deletion... ---'
                                }

                                echo '--- Step 2: Destroying VPC & Remaining Resources ---'
                                sh 'terraform destroy -input=false -auto-approve'

                            } else if (params.ACTION == 'Plan') {
                                sh 'terraform plan -input=false'
                            }
                        }
                    }
                }
            }
        }

        stage('Post-Deployment Verification') {
            when {
                expression { 
                    return params.ACTION in ['Apply-All', 'Apply-EKS-Only'] 
                }
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials-id',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    script {
                        echo '--- Configuring kubeconfig and verifying cluster health ---'
                        
                        sh '''
                            aws eks update-kubeconfig \
                              --region us-east-1 \
                              --name gitops-eks-cluster
                        '''

                        sh '''
                            echo "=== Cluster Nodes ==="
                            kubectl get nodes -o wide
                            
                            echo "=== Waiting for Nodes to reach Ready status ==="
                            kubectl wait --for=condition=Ready nodes --all --timeout=120s
                        '''

                        sh '''
                            echo "=== kube-system Pods ==="
                            kubectl get pods -n kube-system
                            
                            echo "=== Waiting for CoreDNS pods to be ready ==="
                            kubectl wait --for=condition=Ready pod \
                              -l k8s-app=kube-dns \
                              -n kube-system \
                              --timeout=180s
                        '''
                    }
                }
            }
        }
    }
}
