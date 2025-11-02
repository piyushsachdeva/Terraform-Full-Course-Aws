# ==============================================================================
# TERRAFORM FUNCTIONS LEARNING - AWS EDITION
# ==============================================================================
# This file contains 12 assignments demonstrating Terraform built-in functions
# Follow the DEMO_GUIDE.md for step-by-step instructions
# Uncomment each assignment block one at a time to test individual functions
# ==============================================================================

# ==============================================================================
# ASSIGNMENT 1: Project Naming Convention
# ==============================================================================
# Functions: lower(), replace()
# Uncomment to test
# ==============================================================================

# locals {
#   # Transform "Project ALPHA Resource" to "project-alpha-resource"
#   formatted_project_name = lower(replace(var.project_name, " ", "-"))
# }

# resource "aws_resourcegroups_group" "project" {
#   name = local.formatted_project_name

#   resource_query {
#     query = jsonencode({
#       ResourceTypeFilters = ["AWS::AllSupported"]
#       TagFilters = [{
#         Key    = "Project"
#         Values = [local.formatted_project_name]
#       }]
#     })
#   }

#   tags = {
#     Name    = local.formatted_project_name
#     Project = local.formatted_project_name
#   }
# }

# ==============================================================================
# ASSIGNMENT 2: Resource Tagging
# ==============================================================================
# Function: merge()
# Uncomment to test
# ==============================================================================

# locals {
#   # Merge default tags with environment-specific tags
#   merged_tags = merge(var.default_tags, var.environment_tags)
# }

# resource "aws_vpc" "tagged_vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = local.merged_tags
# }

# ==============================================================================
# ASSIGNMENT 3: S3 Bucket Naming
# ==============================================================================
# Functions: substr(), replace(), lower()
# Uncomment to test
# ==============================================================================

# locals {
#   # S3 bucket names: max 63 chars, lowercase, no spaces or special chars
#   formatted_bucket_name = replace(
#     replace(
#       lower(substr(var.bucket_name, 0, 63)),
#       " ", ""
#     ),
#     "!", ""
#   )
# }

# resource "aws_s3_bucket" "storage" {
#   bucket = local.formatted_bucket_name

#   tags = {
#     Name        = local.formatted_bucket_name
#     Environment = var.environment
#   }
# }

# ==============================================================================
# ASSIGNMENT 4: Security Group Port Configuration
# ==============================================================================
# Functions: split(), join(), for expression
# Uncomment to test
# ==============================================================================

# locals {
#   # Split comma-separated ports into list
#   port_list = split(",", var.allowed_ports)

#   # Create security group rules data structure
#   sg_rules = [for port in local.port_list : {
#     name        = "port-${port}"
#     port        = port
#     description = "Allow traffic on port ${port}"
#   }]

#   # Format for documentation: "port-80-port-443-port-8080-port-3306"
#   formatted_ports = join("-", [for port in local.port_list : "port-${port}"])
# }

# # Create a VPC specifically for this assignment (independent of Assignment 2)
# resource "aws_vpc" "sg_vpc" {
#   cidr_block = "10.1.0.0/16"

#   tags = {
#     Name       = "security-group-demo-vpc"
#     Assignment = "4"
#   }
# }

# resource "aws_security_group" "app_sg" {
#   name        = "app-security-group"
#   description = "Security group with dynamic ports"
#   vpc_id      = aws_vpc.sg_vpc.id

#   dynamic "ingress" {
#     for_each = { for rule in local.sg_rules : rule.name => rule }
#     content {
#       description = ingress.value.description
#       from_port   = tonumber(ingress.value.port)
#       to_port     = tonumber(ingress.value.port)
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "app-security-group"
#   }
# }

# ==============================================================================
# ASSIGNMENT 5: Environment Configuration Lookup
# ==============================================================================
# Function: lookup()
# Uncomment to test
# ==============================================================================

# locals {
#   # Lookup instance size based on environment, with fallback
#   instance_size = lookup(var.instance_sizes, var.environment, "t2.micro")
# }

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# resource "aws_instance" "app_server" {
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = local.instance_size

#   tags = {
#     Name        = "app-server-${var.environment}"
#     Environment = var.environment
#     Size        = local.instance_size
#   }
# }

# ==============================================================================
# ASSIGNMENT 6: Instance Type Validation
# ==============================================================================
# Functions: length(), contains(), can(), regex()
# Note: Validation is already in variables.tf
# Uncomment to test
# ==============================================================================

# This assignment demonstrates validation in variables.tf
# Try changing var.instance_type to test validations:
# - "t"           -> Too short (fails)
# - "m5.large"    -> Doesn't start with t2/t3 (fails)
# - "t2.micro"    -> Valid (passes)

# data "aws_ami" "validated_ami" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# resource "aws_instance" "validated_instance" {
#   ami           = data.aws_ami.validated_ami.id
#   instance_type = var.instance_type

#   tags = {
#     Name = "validated-instance"
#     Type = var.instance_type
#   }
# }

# ==============================================================================
# ASSIGNMENT 7: Backup Configuration
# ==============================================================================
# Functions: endswith(), sensitive attribute
# Note: Validation is in variables.tf
# Uncomment to test
# ==============================================================================

# # Backup configuration with validation and sensitive data handling
# locals {
#   backup_config = {
#     name       = var.backup_name
#     credential = var.credential  # Marked as sensitive in variables.tf
#     enabled    = true
#   }
# }

# ==============================================================================
# ASSIGNMENT 8: File Path Processing
# ==============================================================================
# Functions: fileexists(), dirname(), file()
# Uncomment to test
# ==============================================================================

# locals {
#   # Check if files exist
#   config_files = [
#     "./configs/main.tf",
#     "./configs/variables.tf"
#   ]
  
#   file_status = { for file_path in local.config_files :
#     file_path => fileexists(file_path)
#   }
  
#   # Extract directory names
#   config_dirs = { for file_path in local.config_files :
#     file_path => dirname(file_path)
#   }
# }

# ==============================================================================
# ASSIGNMENT 9: Resource Location Management
# ==============================================================================
# Functions: toset(), concat()
# Uncomment to test
# ==============================================================================

# locals {
#   # Combine location lists and remove duplicates
#   all_locations    = concat(var.user_locations, var.default_locations)
#   unique_locations = toset(local.all_locations)
# }

# ==============================================================================
# ASSIGNMENT 10: Cost Calculation
# ==============================================================================
# Functions: abs(), max(), for expression
# Uncomment to test
# ==============================================================================

# locals {
#   # Convert negative values (credits) to positive
#   positive_costs = [for cost in var.monthly_costs : abs(cost)]
#   
#   # Find maximum cost
#   max_cost = max(local.positive_costs...)
#   
#   # Calculate total
#   total_cost = sum(local.positive_costs)
#   
#   # Calculate average
#   avg_cost = local.total_cost / length(local.positive_costs)
# }

# ==============================================================================
# ASSIGNMENT 11: Timestamp Management
# ==============================================================================
# Functions: timestamp(), formatdate()
# Uncomment to test
# ==============================================================================

# locals {
#   # Generate current timestamp
#   current_timestamp = timestamp()
#   
#   # Format for resource names: YYYYMMDD
#   resource_date_suffix = formatdate("YYYYMMDD", local.current_timestamp)
#   
#   # Format for tags: DD-MM-YYYY
#   tag_date_format = formatdate("DD-MM-YYYY", local.current_timestamp)
#   
#   # Create timestamped resource name
#   timestamped_name = "backup-${local.resource_date_suffix}"
# }

# resource "aws_s3_bucket" "timestamped_bucket" {
#   bucket = "my-backup-${local.resource_date_suffix}"
#   
#   tags = {
#     Name       = local.timestamped_name
#     CreatedOn  = local.tag_date_format
#     Timestamp  = local.current_timestamp
#   }
# }

# ==============================================================================
# ASSIGNMENT 12: File Content Handling
# ==============================================================================
# Functions: file(), jsondecode(), sensitive()
# Uncomment to test (requires config.json file)
# ==============================================================================

# # Note: Create a config.json file first to test this
# # Example config.json:
# # {
# #   "database": {
# #     "host": "db.example.com",
# #     "port": 5432,
# #     "username": "admin"
# #   }
# # }

# locals {
#   # Read and parse JSON configuration file
#   config_file_exists = fileexists("./config.json")
#   
#   config_data = local.config_file_exists ? jsondecode(file("./config.json")) : {
#     database = {
#       host     = "localhost"
#       port     = 5432
#       username = "default"
#     }
#   }
# }

# # Store sensitive configuration in AWS Secrets Manager
# resource "aws_secretsmanager_secret" "app_config" {
#   name        = "app-configuration-${formatdate("YYYYMMDD-hhmm", timestamp())}"
#   description = "Application configuration from file"
#   
#   tags = {
#     Name        = "app-config"
#     Sensitive   = "true"
#     ConfigFile  = "./config.json"
#   }
# }

# resource "aws_secretsmanager_secret_version" "app_config" {
#   secret_id     = aws_secretsmanager_secret.app_config.id
#   secret_string = jsonencode(local.config_data)
# }

# ==============================================================================
# DATA SOURCES (Available for all assignments)
# ==============================================================================

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}
