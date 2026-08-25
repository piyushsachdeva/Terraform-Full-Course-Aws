pipeline {
    agent any

    // Optional: automatically provision Terraform CLI if HashiCorp Terraform plugin is configured in Tools
    tools {
        terraform 'terraform-default' // Name defined under Manage Jenkins -> Tools
    }

    parameters {
        string(name: 'GIT_REPO', defaultValue: 'https://github.com/your-org/your-repo.git')
        string(name: 'GIT_BRANCH', defaultValue: 'main')
        choice(name: 'ACTION', choices: ['Apply', 'Destroy'])
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
                // Pass AWS credentials directly to the Terraform execution directory
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials-id', // ID from Jenkins Credentials store
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir('lessons/day29/terraform') {
                        sh 'terraform init'
                        
                        script {
                            if (params.ACTION == 'Apply') {
                                sh 'terraform plan -out=tfplan'
                                sh 'terraform apply -input=false tfplan'
                            } else if (params.ACTION == 'Destroy') {
                                sh 'terraform destroy --auto-approve'
                            }
                        }
                    }
                }
            }
        }
    }
}