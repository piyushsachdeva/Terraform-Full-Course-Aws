# Provider configuration separated for clarity.
variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

# NOTE: If you want to use a remote backend (S3 + DynamoDB) place config in backend.tf
