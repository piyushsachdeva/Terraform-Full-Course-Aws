pipeline {
    agent any

    // Optional: automatically provision Terraform CLI if HashiCorp Terraform plugin is configured in Tools
    //tools {
    //    terraform 'terraform-default' // Name defined under Manage Jenkins -> Tools
    //}

    parameters {
        string(name: 'GIT_REPO', defaultValue: 'https://github.com/your-org/your-repo.git')
        string(name: 'GIT_BRANCH', defaultValue: 'main')
        choice(name: 'ACTION', choices: ['Plan', 'Apply', 'Destroy'])
    }

    stages {
        stage('Clean and Prep Workspace') {
            steps {
                cleanWs()
                // Explicitly verify and create workspace root if needed
                sh 'mkdir -p ${WORKSPACE}'
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
                        script {
                            // 1. Always initialize backend first to pull state from S3
                            sh 'terraform init -input=false'

                            if (params.ACTION == 'Apply') {
                                // Generate plan and apply the precise plan file generated
                                sh 'terraform plan -input=false -out=tfplan'
                                sh 'terraform apply -input=false tfplan'
                            } else if (params.ACTION == 'Destroy') {
                                // Destroy target resources using remote state
                                sh 'terraform destroy -input=false --auto-approve'
                            } else if (params.ACTION == 'Plan') {
                                // Generate plan without applying
                                sh 'terraform plan -input=false -out=tfplan'
                            }
                        }
                    }
                }
            }
        }
    }
}
