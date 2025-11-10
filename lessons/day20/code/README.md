# AWS Infrastructure Project

This project sets up a production-grade AWS infrastructure using Terraform. It includes various components such as VPC, subnets, security groups, Elastic IP, load balancer, auto-scaling groups, NAT gateway, auto-scaling policies, S3 storage, and EC2 user data scripts.

## Project Structure

- **main.tf**: Main configuration file for Terraform, including provider configuration and references to other files.
- **variables.tf**: Defines input variables for the Terraform configuration.
- **outputs.tf**: Specifies output values to be displayed after infrastructure creation.
- **vpc.tf**: Configuration for the Amazon VPC, including subnets and route tables.
- **security_groups.tf**: Defines AWS Security Groups and NACLs with inbound and outbound rules.
- **alb.tf**: Configuration for the Application Load Balancer, target groups, and listener rules.
- **asg.tf**: Defines the Auto Scaling Group configuration, including launch configuration and scaling policies.
- **s3.tf**: Configuration for the Amazon S3 bucket, including access policies and lifecycle rules.
- **scripts/user_data.sh**: Shell script for EC2 instance user data to install software and configure the instance on startup.

## Prerequisites

- Terraform installed on your local machine.
- AWS account with appropriate permissions to create resources.
- AWS CLI configured with your credentials.

## Deployment Instructions

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Review the planned actions:
   ```
   terraform plan
   ```
5. Apply the configuration to create the infrastructure:
   ```
   terraform apply
   ```
6. Follow the output instructions to access your resources.

## Cleanup

To destroy the infrastructure and avoid incurring charges, run:
```
terraform destroy
```

## Notes

- Ensure that you have the necessary IAM permissions to create the resources defined in this project.
- Modify the `variables.tf` file to customize the configuration as needed.