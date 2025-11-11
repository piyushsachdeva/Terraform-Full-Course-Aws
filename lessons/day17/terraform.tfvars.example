# Example terraform.tfvars file
# Copy this file to terraform.tfvars and customize as needed

# AWS Region where resources will be created
aws_region = "us-east-1"

# Name of the Elastic Beanstalk application
# This will be used as a prefix for all resources
app_name = "my-app-bluegreen"

# Solution stack (platform) for Elastic Beanstalk
# To see available stacks, run:
# aws elasticbeanstalk list-available-solution-stacks --region us-east-1
solution_stack_name = "64bit Amazon Linux 2023 v6.2.0 running Node.js 20"

# EC2 instance type for the environments
# Options: t3.micro, t3.small, t3.medium, etc.
instance_type = "t3.micro"

# Tags to apply to all resources
tags = {
  Project     = "BlueGreenDeployment"
  Environment = "Demo"
  ManagedBy   = "Terraform"
  Owner       = "YourName"
}
