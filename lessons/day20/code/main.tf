# EKS Cluster Configuration with Custom Modules
# Day 20: Custom Module Demo for EKS, VPC, IAM, and Secrets Manager

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Custom VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix     = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  # Required tags for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }
}

# Custom IAM Module
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }
}

# Custom EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets

  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_group_role_arn

  endpoint_public_access  = true
  endpoint_private_access = true
  public_access_cidrs     = ["0.0.0.0/0"]

  enable_irsa = true

  # Node groups configuration
  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      capacity_type  = "ON_DEMAND"
      disk_size      = 20

      labels = {
        role = "general"
      }

      tags = {
        NodeGroup = "general"
      }
    }

    spot = {
      instance_types = ["t3.medium", "t3a.medium"]
      desired_size   = 1
      min_size       = 1
      max_size       = 3
      capacity_type  = "SPOT"
      disk_size      = 20

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]

      tags = {
        NodeGroup = "spot"
      }
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }

  depends_on = [module.iam]
}

# Custom Secrets Manager Module (Optional - for demo)
module "secrets_manager" {
  source = "./modules/secrets-manager"

  name_prefix = var.cluster_name

  # Enable secrets as needed
  create_db_secret         = var.enable_db_secret
  create_api_secret        = var.enable_api_secret
  create_app_config_secret = var.enable_app_config_secret

  # Database credentials (if enabled)
  db_username = var.db_username
  db_password = var.db_password
  db_engine   = var.db_engine
  db_host     = var.db_host
  db_port     = var.db_port
  db_name     = var.db_name

  # API keys (if enabled)
  api_key    = var.api_key
  api_secret = var.api_secret

  # App config (if enabled)
  app_config = var.app_config

  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "EKS-Day20"
  }
}
