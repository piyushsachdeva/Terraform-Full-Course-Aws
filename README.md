# Terraform with AWS - Complete Video Course 🚀

Welcome to the comprehensive Terraform with AWS video course! This repository contains all code samples and documentation corresponding to each video lesson.

## 🎯 Course Overview
This course consists of video lessons covering basic to advanced Terraform concepts with AWS cloud, including hands-on projects and real-world scenarios.

## 📋 Prerequisites
- AWS free account or subscription
- AWS Fundamentals
- Visual Studio Code or preferred IDE
- Git installed and working knowledge of it
- Linux or Mac or WSL(Windows Subsystem for Linux)
- Linux and Shell scripting
- Basic understanding of YAML and JSON
- Networking Fundamentals
- IP Addressing
- Docker and Kubernetes Fundamentals

## 📚 Course Curriculum

### Module 1: Core Concepts

#### Day1: Introduction to Terraform
- Understanding Infrastructure as Code (IaC)
- Why we need IaC
- What is Terraform and its benefits
- Challenges with the traditional approach
- Terraform Workflow
- Installing Terraform
- [Code Sample](/lessons/day01/)

#### Day2: Terraform Provider
- Terraform Providers
- Provider version v/s Terraform core version
- Why version matters
- Version constraints
- Operators for versions
- [Code Sample](/lessons/day02/)

#### Day3: VPC and S3 Bucket
- Authentication and Authorization to AWS resources
- Creating VPC
- S3 bucket management
- Understanding dependencies
- [Code Sample](/lessons/day03/)

#### Day4: State file management - Remote Backend
- How Terraform updates Infra
- Terraform state file
- State file best practices
- Remote backend setup
- State management
- [Code Sample](/lessons/day04/)

#### Day5: Variables
- Input variables
- Output variables
- Locals
- Variable precedence
- Variable files (tfvars)
- [Code Sample](/lessons/day05/)

#### Day6: File Structure
- Terraform file organization
- Sequence of file loading
- Best practices for structure
- [Code Sample](/lessons/day06/)

#### Video 7: Type constraints in Terraform
- String, number, bool
- Map, set, list, Tuple, Objects
- [Code Sample](/lessons/day07/)

#### Video 8: Meta-arguments
- Understanding count
- for_each loop
- for loop
- Practical examples
- [Code Sample](/lessons/day08)

#### Video 9: The Lifecycle meta-arguments
- create before destroy
- prevent destroy
- ignore changes
- replace triggered by
- custom condition
- [Code Sample](/lessons/day09)

#### Video 10: Dynamic Blocks and expressions
- Dynamic blocks
- Conditional expressions
- Splat Expressions
- practical examples
- [Code Sample](/lessons/day10)

#### Video 11: Functions in Terraform
- Built-in functions
- Practical examples
- tasks for practice
- [Code Sample](/lessons/day11)

#### Video 12: Functions in Terraform(Continue..)
- Built-in functions
- Practical examples
- tasks for practice
- [Code Sample](/lessons/day12)

#### Video 13: Data Sources
- Using data sources
- Practical examples
- [Code Sample](/lessons/day13)
  
### Module 2: AWS resources using Terraform 

#### Video 24: Static Website Hosting ( Mini Project 1 )
- S3 static website hosting
- CloudFront distribution
- Route 53 DNS configuration
- SSL/TLS certificate management
- [Code Sample](/lessons/day14)


#### Video 15: VPC and Peering ( Mini Project 2 )
- Virtual Private Cloud Creation
- VPC peering setup
- [Code Sample](/lessons/day15)

#### Video 16: IAM Authentication ( Mini Project 3 )
- Authentication methods
- IAM roles and policies
- Service accounts
- [Code Sample](/lessons/day16)

#### Video 17: AWS Web Apps ( Mini Project 4 )
- Elastic Beanstalk creation
- Configuration
- Deployment
- [Code Sample](/lessons/day17)

#### Video 18: AWS Lambda ( Mini Project 5 )
- Lambda function setup
- Configuration
- [Code Sample](/lessons/day18)

#### Video 19: Terraform Provisioners ( Mini Project 6 )
- What are provisioners and their use case
- Local vs remote vs file provisioners
- Demo of all three provisioners
- [Code Sample](/lessons/day19)

#### Video 20: EKS Cluster ( Real-time Project 1)
- Kubernetes cluster setup
- EKS cluster with managed node groups
- Custom module usage
- Custom module creation for EKS, Secrets Manager, IAM etc
- Networking and security configuration
- [Code Sample](/lessons/day20)

#### Video 21: AWS Policy and Governance ( Mini Project 7 )
- Policy creation
- Governance setup
- [Code Sample](/lessons/day21)

#### Video 22: RDS Database ( Mini Project 8 )
- Database creation
- Configuration
- [Code Sample](/lessons/day22)

#### Video 23: AWS Monitoring ( Mini Project 9 )
- CloudWatch metrics alerts
- SNS topics
- CloudWatch logs
- Log alerts
- [Code Sample](/lessons/day23)

#### Video 24: High available/scalable Infrastructure Deployment ( Mini Project 10 )

- Creating EC2 Instances
- Auto Scaling Groups
- Security Groups
- Application Load Balancer, NAT Gateway, Elastic IP, Auto Scaling rules etc
- [Code Sample](/lessons/day24)

### Module 3: Advanced Concepts

#### Video 25: Terraform Import (Real-time project 2)
- Different ways of importing AWS resource to Terraform
- Terraform Import
- Importing a live infrastructure to Terraform using Terraform Import
- AWS Config
- Importing a live infrastructure to Terraform using AWS Config
- Terraformer
- [Code Sample](/lessons/day25)

#### Video 26: Terraform Cloud and Workspaces
- Cloud setup
- Workspace management
- [Code Sample](/lessons/day26)

#### Video 27: AWS DevOps with Terraform (Real-time project 3)
- CI/CD pipeline setup
- Automation
- [Code Sample](/lessons/day27)


#### Video 28: 3-Tier Architecture (Real-time project 5)
- Complete architecture setup
- Web tier, Application tier, Database tier
- Load balancing and auto-scaling
- Best practices
- [Code Sample](/lessons/day29)

#### Video 29: GitOps with Terraform (Real-time project 4)

- GitOps workflow implementation
- ArgoCD setup with Terraform
- Git-based infrastructure management
- Automated deployments
- [Code Sample](/lessons/day30)


### Video 0: Terrafrom Drift Detection using Terraform Cloud
- Drift detection setup
- Monitoring infrastructure changes
- [Code Sample](/lessons/day31)



## 📂 Repository Structure
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

## 🎓 Learning Path
1. Follow videos in sequence
2. Complete hands-on exercises
3. Implement projects
4. Practice with provided code samples

## 📝 License
MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Course Support Forum]()
