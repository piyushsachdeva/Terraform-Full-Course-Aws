# IAM Module

This module creates IAM roles and instance profiles for EC2 instances in the Goal Tracker application.

## Features

- EC2 instance role with assume role policy
- ECR read-only access for pulling container images
- Systems Manager (SSM) access for Session Manager
- CloudWatch Agent permissions for logs and metrics
- Secrets Manager access for database credentials
- Instance profile for EC2 attachment

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"

  environment  = "dev"
  project      = "goal-tracker"
  secrets_arns = [module.secrets.db_secret_arn]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | string | - | yes |
| project | Project name | string | - | yes |
| secrets_arns | Secrets Manager ARNs | list(string) | ["*"] | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2_role_arn | EC2 IAM role ARN |
| ec2_role_name | EC2 IAM role name |
| ec2_instance_profile_arn | Instance profile ARN |
| ec2_instance_profile_name | Instance profile name |

## Permissions

The EC2 role includes:
- **AmazonEC2ContainerRegistryReadOnly**: Pull Docker images from ECR
- **AmazonSSMManagedInstanceCore**: Session Manager access (no SSH keys needed)
- **CloudWatchAgentServerPolicy**: Send logs and metrics to CloudWatch
- **Custom Secrets Manager Policy**: Read database credentials
