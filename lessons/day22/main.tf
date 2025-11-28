# Day 22 - RDS Database Mini Project
# Main Configuration - Root Module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_security_group_id = module.security_groups.db_sg_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  engine_version       = var.db_engine_version
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.ec2_instance_type
  public_subnet_id      = module.vpc.public_subnet_id
  web_security_group_id = module.security_groups.web_sg_id
  db_host               = module.rds.db_endpoint
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
}
