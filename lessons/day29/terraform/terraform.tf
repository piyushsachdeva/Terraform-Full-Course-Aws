terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "vitninlab-tf-state-prod-gitops"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.59.0" # Updated from ~> 5.0 to satisfy EKS v21 requirements
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
