# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  project               = var.project
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  frontend_subnet_cidrs = var.frontend_subnet_cidrs
  backend_subnet_cidrs  = var.backend_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway

  tags = var.tags
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  environment       = var.environment
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = [var.allowed_ssh_cidr]

  tags = var.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project      = var.project
  secrets_arns = ["*"] # Will be updated after secrets are created

  tags = var.tags
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment             = var.environment
  project                 = var.project
  subnet_ids              = module.vpc.database_subnet_ids
  security_group_id       = module.security_groups.rds_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = random_password.db_password.result
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = var.tags
}

# Secrets Manager Module
module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  project     = var.project
  db_username = var.db_username
  db_password = random_password.db_password.result
  db_host     = module.rds.db_address
  db_port     = module.rds.db_port
  db_name     = var.db_name

  tags = var.tags
}

# Bastion Module
module "bastion" {
  source = "../../modules/bastion"

  environment          = var.environment
  project              = var.project
  instance_type        = var.bastion_instance_type
  key_name             = var.ssh_key_name
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_id    = module.security_groups.bastion_sg_id
  iam_instance_profile = module.iam.ec2_instance_profile_name

  tags = var.tags
}

# Public Application Load Balancer Module (Frontend)
module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  project           = var.project
  name_prefix       = "public-"
  internal          = false
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  target_group_port = 3000

  tags = var.tags
}

# Internal Application Load Balancer Module (Backend)
module "internal_alb" {
  source = "../../modules/alb"

  environment       = var.environment
  project           = var.project
  name_prefix       = "internal-"
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.frontend_subnet_ids # Note: Using Frontend subnets for reachability
  security_group_id = module.security_groups.internal_alb_sg_id
  target_group_port = 8080

  tags = var.tags
}

# Frontend ASG Module
module "frontend_asg" {
  source = "../../modules/frontend-asg"

  environment          = var.environment
  project              = var.project
  region               = var.region
  instance_type        = var.frontend_instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.frontend_sg_id
  subnet_ids           = module.vpc.frontend_subnet_ids
  target_group_arn     = module.alb.target_group_arn
  min_size             = var.frontend_min_size
  max_size             = var.frontend_max_size
  desired_capacity     = var.frontend_desired_capacity

  docker_image         = var.frontend_docker_image
  dockerhub_username   = var.dockerhub_username
  dockerhub_password   = var.dockerhub_password
  backend_internal_url = "http://${module.internal_alb.alb_dns_name}"

  tags = var.tags

  depends_on = [module.rds, module.alb, module.internal_alb]
}

# Backend ASG Module
module "backend_asg" {
  source = "../../modules/backend-asg"

  environment          = var.environment
  project              = var.project
  region               = var.region
  instance_type        = var.backend_instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.backend_sg_id
  subnet_ids           = module.vpc.backend_subnet_ids
  target_group_arns    = [module.internal_alb.target_group_arn]
  min_size             = var.backend_min_size
  max_size             = var.backend_max_size
  desired_capacity     = var.backend_desired_capacity

  docker_image       = var.backend_docker_image
  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password
  db_secret_arn      = module.secrets.db_secret_arn

  tags = var.tags

  depends_on = [module.rds, module.secrets]
}
