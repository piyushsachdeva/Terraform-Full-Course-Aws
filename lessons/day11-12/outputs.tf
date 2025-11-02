# ==============================================================================
# ASSIGNMENT 1 OUTPUTS: Project Naming
# ==============================================================================

# output "formatted_project_name" {
#   description = "Formatted project name (lowercase with hyphens)"
#   value       = local.formatted_project_name
# }

# output "resource_group_name" {
#   description = "Created resource group name"
#   value       = aws_resourcegroups_group.project.name
# }

# ==============================================================================
# ASSIGNMENT 2 OUTPUTS: Resource Tagging
# ==============================================================================
# Uncomment when testing Assignment 2

# output "merged_tags" {
#   description = "Combined default and environment tags"
#   value       = local.merged_tags
# }

# output "vpc_tags" {
#   description = "Tags applied to VPC"
#   value       = aws_vpc.tagged_vpc.tags
# }

# ==============================================================================
# ASSIGNMENT 3 OUTPUTS: S3 Bucket Naming
# ==============================================================================
# Uncomment when testing Assignment 3

# output "original_bucket_name" {
#   description = "Original bucket name input"
#   value       = var.bucket_name
# }

# output "formatted_bucket_name" {
#   description = "Formatted S3-compliant bucket name"
#   value       = local.formatted_bucket_name
# }

# output "bucket_arn" {
#   description = "ARN of created S3 bucket"
#   value       = aws_s3_bucket.storage.arn
# }

# ==============================================================================
# ASSIGNMENT 4 OUTPUTS: Security Group Ports
# ==============================================================================
# Uncomment when testing Assignment 4

# output "port_list" {
#   description = "List of ports from comma-separated string"
#   value       = local.port_list
# }

# output "security_group_rules" {
#   description = "Generated security group rules"
#   value       = local.sg_rules
# }

# output "formatted_ports" {
#   description = "Formatted port string for documentation"
#   value       = local.formatted_ports
# }

# output "security_group_id" {
#   description = "ID of created security group"
#   value       = aws_security_group.app_sg.id
# }

# ==============================================================================
# ASSIGNMENT 5 OUTPUTS: Environment Configuration
# ==============================================================================
# Uncomment when testing Assignment 5

# output "environment" {
#   description = "Current environment"
#   value       = var.environment
# }

# output "instance_size" {
#   description = "Instance size selected via lookup"
#   value       = local.instance_size
# }

# output "instance_id" {
#   description = "ID of created EC2 instance"
#   value       = aws_instance.app_server.id
# }

# ==============================================================================
# ASSIGNMENT 6 OUTPUTS: Instance Type Validation
# ==============================================================================
# Uncomment when testing Assignment 6

# output "validated_instance_type" {
#   description = "Validated instance type"
#   value       = var.instance_type
# }

# output "validated_instance_id" {
#   description = "ID of validated instance"
#   value       = aws_instance.validated_instance.id
# }

# ==============================================================================
# ASSIGNMENT 7 OUTPUTS: Backup Configuration
# ==============================================================================
# Uncomment when testing Assignment 7

# output "backup_name" {
#   description = "Backup configuration name (validated)"
#   value       = var.backup_name
# }

# output "backup_credential" {
#   description = "Backup credential (sensitive)"
#   value       = var.credential
#   sensitive   = true
# }

# output "backup_config" {
#   description = "Complete backup configuration"
#   value       = local.backup_config
#   sensitive   = true
# }

# ==============================================================================
# ASSIGNMENT 8 OUTPUTS: File Path Processing
# ==============================================================================
# Uncomment when testing Assignment 8

# output "file_existence_status" {
#   description = "Status of each configuration file"
#   value       = local.file_status
# }

# output "config_directories" {
#   description = "Directory paths extracted from file paths"
#   value       = local.config_dirs
# }

# ==============================================================================
# ASSIGNMENT 9 OUTPUTS: Location Management
# ==============================================================================
# Uncomment when testing Assignment 9

  # output "all_locations" {
  #   description = "Combined list of all locations (with duplicates)"
  #   value       = local.all_locations
  # }

  # output "unique_locations" {
  #   description = "Unique set of locations (duplicates removed)"
  #   value       = local.unique_locations
  # }

  # output "location_count" {
  #   description = "Number of unique locations"
  #   value       = length(local.unique_locations)
  # }

# ==============================================================================
# ASSIGNMENT 10 OUTPUTS: Cost Calculation
# ==============================================================================
# Uncomment when testing Assignment 10

# output "original_costs" {
#   description = "Original monthly costs (with negatives)"
#   value       = var.monthly_costs
# }

# output "positive_costs" {
#   description = "All costs as positive values"
#   value       = local.positive_costs
# }

# output "max_cost" {
#   description = "Maximum monthly cost"
#   value       = local.max_cost
# }

# output "total_cost" {
#   description = "Total monthly cost"
#   value       = local.total_cost
# }

# output "average_cost" {
#   description = "Average monthly cost"
#   value       = local.avg_cost
# }

# ==============================================================================
# ASSIGNMENT 11 OUTPUTS: Timestamp Management
# ==============================================================================
# Uncomment when testing Assignment 11

# output "current_timestamp" {
#   description = "Current timestamp"
#   value       = local.current_timestamp
# }

# output "resource_date_suffix" {
#   description = "Date formatted for resource names (YYYYMMDD)"
#   value       = local.resource_date_suffix
# }

# output "tag_date_format" {
#   description = "Date formatted for tags (DD-MM-YYYY)"
#   value       = local.tag_date_format
# }

# output "timestamped_bucket_name" {
#   description = "Timestamped S3 bucket name"
#   value       = aws_s3_bucket.timestamped_bucket.id
# }

# ==============================================================================
# ASSIGNMENT 12 OUTPUTS: File Content Handling
# ==============================================================================
# Uncomment when testing Assignment 12

# output "config_file_exists" {
#   description = "Whether config.json file exists"
#   value       = local.config_file_exists
# }

# output "config_data" {
#   description = "Configuration data from file (non-sensitive parts only)"
#   value       = { for k, v in local.config_data : k => v if k != "password" }
# }

# output "secret_arn" {
#   description = "ARN of AWS Secrets Manager secret"
#   value       = aws_secretsmanager_secret.app_config.arn
# }

# ==============================================================================
# GENERAL OUTPUTS (Always Available)
# ==============================================================================

output "current_region" {
  description = "Current AWS region"
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "available_azs" {
  description = "Available availability zones"
  value       = data.aws_availability_zones.available.names
}
