# VPC Module

This module creates a complete 3-tier VPC infrastructure for the Goal Tracker application.

## Architecture

### Subnets
- **Public Subnets (Web Tier)**: Internet-facing resources (ALB, Bastion, NAT Gateways)
- **Frontend Subnets (App Tier)**: Node.js frontend application servers
- **Backend Subnets (App Tier)**: Go backend API servers
- **Database Subnets (Data Tier)**: PostgreSQL RDS instances (completely isolated)

### Routing
- Public subnets route to Internet Gateway
- Frontend/Backend subnets route to NAT Gateway for outbound internet access
- Database subnets have no internet access (isolated)

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment        = "dev"
  project            = "goal-tracker"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  frontend_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  backend_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
  database_subnet_cidrs = ["10.0.31.0/24", "10.0.32.0/24"]

  enable_nat_gateway  = true
  single_nat_gateway  = true  # Set to false for multi-AZ NAT (higher cost)

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/16" | no |
| environment | Environment name | string | - | yes |
| project | Project name | string | - | yes |
| availability_zones | List of AZs | list(string) | - | yes |
| public_subnet_cidrs | Public subnet CIDRs | list(string) | - | yes |
| frontend_subnet_cidrs | Frontend subnet CIDRs | list(string) | - | yes |
| backend_subnet_cidrs | Backend subnet CIDRs | list(string) | - | yes |
| database_subnet_cidrs | Database subnet CIDRs | list(string) | - | yes |
| enable_nat_gateway | Enable NAT Gateway | bool | true | no |
| single_nat_gateway | Use single NAT Gateway | bool | false | no |
| tags | Common tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_ids | Public subnet IDs |
| frontend_subnet_ids | Frontend subnet IDs |
| backend_subnet_ids | Backend subnet IDs |
| database_subnet_ids | Database subnet IDs |
| nat_gateway_ips | NAT Gateway Elastic IPs |
| internet_gateway_id | Internet Gateway ID |

## Cost Optimization

For development environments, consider:
- Setting `single_nat_gateway = true` to save ~$32/month
- Disabling NAT Gateway entirely if outbound internet access is not needed
