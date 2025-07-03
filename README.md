# Terraform with AWS - Complete Video Course 🚀
Welcome to the comprehensive Terraform with AWS video course! This repository contains all code samples and documentation corresponding to each video lesson.

🎯 Course Overview
This course consists of video lessons covering basic to advanced Terraform concepts with AWS cloud, including hands-on projects and real-world scenarios.

📋 Prerequisites
• AWS free account or subscription
• AWS Fundamentals
• Visual Studio Code or preferred IDE
• Git installed and working knowledge of it
• Linux or Mac or WSL(Windows Subsystem for Linux)
• Linux and Shell scripting
• Basic understanding of YAML and JSON
• Networking Fundamentals
• IP Addressing
• Docker and Kubernetes Fundamentals

📚 Course Curriculum
### Module 1: Core Concepts
#### Day1: Introduction to Terraform
• Understanding Infrastructure as Code (IaC)
• Why we need IaC
• What is Terraform and its benefits
• Challenges with the traditional approach
• Terraform Workflow
• Installing Terraform
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day01)

#### Day2: Terraform Provider
• Terraform Providers
• Provider version v/s Terraform core version
• Why version matters
• Version constraints
• Operators for versions
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day02)

#### Day3: VPC and S3 Bucket
• Authentication and Authorization to AWS resources
• Creating VPC
• S3 bucket management
• Understanding dependencies
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day03)

#### Day4: State file management - Remote Backend
• How Terraform updates Infra
• Terraform state file
• State file best practices
• Remote backend setup
• State management
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day04)

#### Day5: Variables
• Input variables
• Output variables
• Locals
• Variable precedence
• Variable files (tfvars)
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day05)

#### Day6: File Structure
• Terraform file organization
• Sequence of file loading
• Best practices for structure
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day06)

#### Video 7: Type constraints in Terraform
• String, number, bool
• Map, set, list, Tuple, Objects
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day07)

#### Video 8: Meta-arguments
• Understanding count
• for_each loop
• for loop
• Practical examples
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day08)

#### Video 9: The Lifecycle meta-arguments
• create before destroy
• prevent destroy
• ignore changes
• replace triggered by
• custom condition
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day09)

#### Video 10: Dynamic Blocks and expressions
• Dynamic blocks
• Conditional expressions
• Splat Expressions
• practical examples
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day10)

#### Video 11: Functions in Terraform
• Built-in functions
• Practical examples
• tasks for practice
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day11)

#### Video 12: Functions in Terraform(Continue..)
• Built-in functions
• Practical examples
• tasks for practice
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day12)

#### Video 13: Data Sources
• Using data sources
• Practical examples
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day13)

### Module 2: AWS resources using Terraform
#### Video 14: High available/scalable Infrastructure Deployment ( Mini Project 1 )
• Creating EC2 Instances
• Auto Scaling Groups
• Security Groups
• Application Load Balancer, NAT Gateway, Elastic IP, Auto Scaling rules etc
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day14)

#### Video 15: VPC and Peering ( Mini Project 2 )
• Virtual Private Cloud Creation
• VPC peering setup
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day15)

#### Video 16: IAM Authentication ( Mini Project 3 )
• Authentication methods
• IAM roles and policies
• Service accounts
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day16)

#### Video 17: AWS Web Apps ( Mini Project 4 )
• Elastic Beanstalk creation
• Configuration
• Deployment
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day17)

#### Video 18: AWS Lambda ( Mini Project 5 )
• Lambda function setup
• Configuration
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day18)

#### Video 19: Terraform Provisioners ( Mini Project 6 )
• What are provisioners and their use case
• Local vs remote vs file provisioners
• Demo of all three provisioners
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day19)

#### Video 20: EKS Cluster ( Real-time Project 1)
• Kubernetes cluster setup
• Custom module usage
• Custom module creation for EKS, Secrets Manager, IAM etc
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day20)

#### Video 21: AWS Policy and Governance ( Mini Project 7 )
• Policy creation
• Governance setup
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day21)

#### Video 22: RDS Database ( Mini Project 8 )
• Database creation
• Configuration
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day22)

#### Video 23: AWS Monitoring ( Mini Project 9 )
• CloudWatch metrics alerts
• SNS topics
• CloudWatch logs
• Log alerts
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day23)

### Module 3: Advanced Concepts
#### Video 24: Terraform Import (Real-time project 2)
• Different ways of importing AWS resource to Terraform
• Terraform Import
• Importing a live infrastructure to Terraform using Terraform Import
• AWS Config
• Importing a live infrastructure to Terraform using AWS Config
• Terraformer
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day24)

#### Video 25: Terraform Cloud and Workspaces
• Cloud setup
• Workspace management
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day25)

#### Video 26: AWS DevOps with Terraform (Real-time project 3)
• CI/CD pipeline setup
• Automation
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day26)

#### Video 27: 3-Tier Architecture (Real-time project 4)
• Complete architecture setup
• Best practices
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day27)

#### Video 28: EKS Upgrade with Zero Downtime (Real-time project 5)
• Upgrade strategy
• Implementation
• [Code Sample](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/lessons/day28)

📂 Repository Structure
```
├── lessons/
│   ├── day01/
│   ├── day02/
│   └── ...
├── docs/
│   ├── setup.md
│   └── troubleshooting.md
└── README.md
```

🎓 Learning Path
1. Follow videos in sequence
2. Complete hands-on exercises
3. Implement projects
4. Practice with provided code samples

📝 License
MIT License - see the [LICENSE](https://github.com/baivab/Terraform-Full-Course-Aws/blob/main/LICENSE) file for details.

🔗 Resources
• [Terraform Documentation](https://www.terraform.io/docs)
• [AWS Documentation](https://docs.aws.amazon.com/)
• [Course Support Forum](https://github.com/baivab/Terraform-Full-Course-Aws/discussions)
