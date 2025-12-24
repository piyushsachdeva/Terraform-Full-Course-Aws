# Remote State Backend Configuration
# This file configures S3 backend for state management with S3 native locking
# Each environment (dev/prod) will have a separate state file
# Requires Terraform 1.10.0+ for use_lockfile support

terraform {
  backend "s3" {
    # Backend configuration will be provided via backend config file or CLI
    # This allows different state files for dev and prod environments

    # Configuration values provided at init time:
    # bucket        = "terraform-state-bucket-name"
    # key           = "env/terraform.tfstate"  # Will be dev or prod
    # region        = "us-east-1"
    # use_lockfile  = true  # S3 native state locking (Terraform 1.10.0+)
    # encrypt       = true
  }
}
