terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "vitninlab-tf-state-prod-gitops"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"    
  }
}
