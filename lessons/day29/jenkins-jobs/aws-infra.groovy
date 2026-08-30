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

        stage('Preflight Tools') {
            steps {
                sh '''
                    set -e
                    echo '--- Verifying required tools ---'
                    aws --version
                    kubectl version --client
                    terraform version
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
                                sh '''
                                    set +e
                                    terraform destroy -target=module.eks -input=false -auto-approve
                                    destroy_rc=$?

                                    if [ "$destroy_rc" -ne 0 ]; then
                                        echo '--- EKS destroy timed out or hit stale state. Checking AWS and state cleanup ---'
                                        if ! aws eks list-clusters --region us-east-1 --query 'clusters' --output text | grep -q .; then
                                            echo '--- AWS reports no EKS cluster. Removing stale EKS state entries. ---'
                                            terraform state list | grep -E "module\\.eks|aws_eks_addon\\.ebs_csi|aws_iam_role\\.ebs_csi|aws_iam_role_policy_attachment\\.ebs_csi" | while read -r item; do
                                                terraform state rm "$item" || true
                                            done
                                        fi
                                    fi

                                    exit $destroy_rc
                                '''

                            } else if (params.ACTION == 'Destroy-VPC-Only') {
                                echo '--- Safety check: verifying EKS cluster state before VPC destroy ---'

                                def clusterStatus = sh(
                                    script: "aws eks describe-cluster --name gitops-eks-cluster --region us-east-1 --query 'cluster.status' --output text 2>/dev/null || echo 'NOT_FOUND'",
                                    returnStdout: true
                                ).trim()

                                if (clusterStatus != 'NOT_FOUND') {
                                    error("EKS cluster exists, remove EKS first")
                                }

                                echo '--- No active EKS cluster found. Destroying VPC safely: cleaning AWS dependencies first ---'
                                sh '''
                                    set -e
                                    vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=gitops-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)

                                    if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
                                        echo "Found VPC: $vpc_id"

                                        aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].[LoadBalancerArn]" --output text | while read -r lb_arn; do
                                            [ -n "$lb_arn" ] && aws elbv2 delete-load-balancer --load-balancer-arn "$lb_arn" || true
                                        done

                                        aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text | tr '\t' '\n' | while read -r nat_id; do
                                            [ -n "$nat_id" ] && aws ec2 delete-nat-gateway --nat-gateway-id "$nat_id" || true
                                        done
                                    fi

                                    terraform destroy -target=module.vpc -input=false -auto-approve
                                '''

                            } else if (params.ACTION == 'Destroy-All') {
                                echo '--- Destroying all resources safely ---'
                                sh '''
                                    set +e

                                    cluster_status=$(aws eks describe-cluster --name gitops-eks-cluster --region us-east-1 --query 'cluster.status' --output text 2>/dev/null || echo 'NOT_FOUND')

                                    if [ "$cluster_status" != "NOT_FOUND" ]; then
                                        echo "--- Active EKS cluster detected (Status: $cluster_status). Destroying EKS first... ---"
                                        terraform destroy -target=module.eks -input=false -auto-approve
                                        destroy_rc=$?

                                        if [ "$destroy_rc" -ne 0 ]; then
                                            if ! aws eks list-clusters --region us-east-1 --query 'clusters' --output text | grep -q .; then
                                                terraform state list | grep -E "module\\.eks|aws_eks_addon\\.ebs_csi|aws_iam_role\\.ebs_csi|aws_iam_role_policy_attachment\\.ebs_csi" | while read -r item; do
                                                    terraform state rm "$item" || true
                                                done
                                            fi
                                        fi

                                        [ "$destroy_rc" -eq 0 ] || exit "$destroy_rc"
                                    else
                                        echo '--- No active EKS cluster found in AWS. Cleaning stale EKS state if needed. ---'
                                        terraform state list | grep -E "module\\.eks|aws_eks_addon\\.ebs_csi|aws_iam_role\\.ebs_csi|aws_iam_role_policy_attachment\\.ebs_csi" | while read -r item; do
                                            terraform state rm "$item" || true
                                        done
                                    fi

                                    vpc_id=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=gitops-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || true)

                                    if [ -n "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
                                        echo "Found VPC: $vpc_id"

                                        aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$vpc_id'].[LoadBalancerArn]" --output text | while read -r lb_arn; do
                                            [ -n "$lb_arn" ] && aws elbv2 delete-load-balancer --load-balancer-arn "$lb_arn" || true
                                        done

                                        aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text | tr '\t' '\n' | while read -r nat_id; do
                                            [ -n "$nat_id" ] && aws ec2 delete-nat-gateway --nat-gateway-id "$nat_id" || true
                                        done
                                    fi

                                    terraform destroy -input=false -auto-approve
                                '''

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

                            echo "=== Waiting for all nodes to become Ready ==="
                            for i in $(seq 1 30); do
                                ready=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -c True || true)
                                total=$(kubectl get nodes --no-headers | wc -l)
                                if [ "$total" -gt 0 ] && [ "$ready" -eq "$total" ]; then
                                    echo "All nodes are Ready."
                                    break
                                fi
                                echo "Waiting for nodes... ($ready/$total ready)"
                                sleep 10
                            done
                        '''

                        sh '''
                            echo "=== kube-system Pods ==="
                            kubectl get pods -n kube-system

                            echo "=== Waiting for CoreDNS to be ready ==="
                            for i in $(seq 1 30); do
                                ready=$(kubectl get pods -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | tr ' ' '\n' | grep -c true || true)
                                total=$(kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers | wc -l)
                                if [ "$total" -gt 0 ] && [ "$ready" -ge 2 ]; then
                                    echo "CoreDNS is ready."
                                    break
                                fi
                                echo "Waiting for CoreDNS... ($ready/$total ready)"
                                sleep 10
                            done
                        '''
                    }
                }
            }
        }
    }
}
