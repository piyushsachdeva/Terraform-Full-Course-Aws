terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "vitninlab-tf-state-prod-gitops"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true  # S3 Native Locking (Terraform 1.13+)
    encrypt      = true
  }
}
