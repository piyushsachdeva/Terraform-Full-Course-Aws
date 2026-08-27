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
                                echo '--- Destroying VPC Module Only ---'
                                sh 'terraform destroy -target=module.vpc -input=false -auto-approve'

                            } else if (params.ACTION == 'Destroy-All') {
                                echo '--- Step 1: Destroying EKS Cluster First ---'
                                sh 'terraform destroy -target=module.eks -input=false -auto-approve'

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
    }
}