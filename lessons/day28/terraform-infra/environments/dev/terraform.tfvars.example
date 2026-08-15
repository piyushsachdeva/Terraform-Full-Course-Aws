# Example values for development environment
# Copy this file to terraform.tfvars and adjust values

region      = "us-east-1"
environment = "dev"
project     = "goal-tracker"

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
frontend_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
backend_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]
database_subnet_cidrs = ["10.0.31.0/24", "10.0.32.0/24"]
single_nat_gateway   = true  # false for high availability (costs more)

# SSH Configuration
ssh_key_name     = "your-key-pair-name"  # REQUIRED: Replace with your key pair name
allowed_ssh_cidr = "0.0.0.0/0"          # CHANGE THIS: Use your IP address like "1.2.3.4/32"

# Bastion Configuration
bastion_instance_type = "t2.micro"

# Frontend ASG Configuration
frontend_instance_type    = "t3.micro"
frontend_min_size         = 2
frontend_max_size         = 4
frontend_desired_capacity = 2

# Backend ASG Configuration
backend_instance_type    = "t3.micro"
backend_min_size         = 2
backend_max_size         = 6
backend_desired_capacity = 2

# RDS Configuration
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
db_engine_version       = "15.5"
db_name                 = "goalsdb"
db_username             = "postgres"
db_multi_az             = false  # true for high availability
db_backup_retention     = 7
db_skip_final_snapshot  = true   # false for production

# Docker Hub Configuration
frontend_docker_image = "your-dockerhub-username/goal-tracker-frontend:latest"
backend_docker_image  = "your-dockerhub-username/goal-tracker-backend:latest"
dockerhub_username    = ""  # Leave empty for public images
dockerhub_password    = ""  # Leave empty for public images, or use access token

# Tags
tags = {
  Environment = "dev"
  Project     = "goal-tracker"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
