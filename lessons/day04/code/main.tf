# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  # Configuration options
    region = "ca-central-1"
}

# backend configuration
terraform {
  backend "s3" {
    bucket         = "erraform-state-1754513244"
    key            = "dev/terraform.tfstate"
    region         = "ca-central-1"
    use_lockfile  = "true"
    encrypt        = true
  }
}


# Simple test resource to verify remote backend
resource "aws_s3_bucket" "test_backend" {
  bucket = "test-remote-backend-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Test Backend Bucket"
    Environment = "dev"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
