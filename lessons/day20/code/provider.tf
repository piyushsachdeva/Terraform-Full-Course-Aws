# Provider Configuration
# Using AWS Provider 5.x (Compatible with EKS module 20.x)

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "Day20-EKS-Cluster"
    }
  }
}
