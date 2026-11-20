terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = "terraform-day30-workspaces"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "terraform_data" "workspace_guard" {
  input = terraform.workspace

  lifecycle {
    precondition {
      condition     = contains(["dev", "prod"], terraform.workspace)
      error_message = "Select the dev or prod Terraform workspace before planning or applying."
    }
  }
}

locals {
  name_prefix = "day30-${terraform.workspace}"
  is_prod     = terraform.workspace == "prod"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "network" {
  source      = "./modules/network"
  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  azs         = local.azs

  depends_on = [terraform_data.workspace_guard]
}

module "app" {
  source          = "./modules/app"
  name_prefix     = local.name_prefix
  environment     = terraform.workspace
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnet_ids
  private_subnets = module.network.private_subnet_ids
  ami_id          = data.aws_ami.ubuntu.id
  instance_type   = local.is_prod ? "t3.small" : "t3.micro"
  min_size        = local.is_prod ? 2 : 1
  desired_size    = local.is_prod ? 2 : 1
  max_size        = local.is_prod ? 4 : 2
  app_image       = var.app_image

  depends_on = [terraform_data.workspace_guard]
}

module "storage" {
  source      = "./modules/storage"
  name_prefix = local.name_prefix
  environment = terraform.workspace

  depends_on = [terraform_data.workspace_guard]
}
