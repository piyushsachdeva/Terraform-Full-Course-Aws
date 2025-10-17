# ==============================
# EC2 Outputs
# ==============================

output "web_server_id" {
  description = "ID of the web server instance (create_before_destroy example)"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web_server.public_ip
}

output "app_instance_id" {
  description = "ID of app instance with security group (replace_triggered_by example)"
  value       = aws_instance.app_with_sg.id
}

# ==============================
# S3 Outputs
# ==============================

output "critical_bucket_name" {
  description = "Name of the critical S3 bucket (prevent_destroy example)"
  value       = aws_s3_bucket.critical_data.id
}

output "critical_bucket_arn" {
  description = "ARN of the critical S3 bucket"
  value       = aws_s3_bucket.critical_data.arn
}

output "regional_validation_bucket" {
  description = "Name of the region-validated bucket (precondition example)"
  value       = aws_s3_bucket.regional_validation.id
}

output "compliance_bucket_name" {
  description = "Name of the compliance bucket (postcondition example)"
  value       = aws_s3_bucket.compliance_bucket.id
}

output "app_bucket_names" {
  description = "Names of application buckets created with for_each"
  value       = [for bucket in aws_s3_bucket.app_buckets : bucket.id]
}

output "app_bucket_arns" {
  description = "ARNs of application buckets"
  value       = { for key, bucket in aws_s3_bucket.app_buckets : key => bucket.arn }
}

# ==============================
# Auto Scaling Outputs
# ==============================

output "asg_name" {
  description = "Name of the Auto Scaling Group (ignore_changes example)"
  value       = aws_autoscaling_group.app_servers.name
}

output "asg_min_size" {
  description = "Minimum size of the ASG"
  value       = aws_autoscaling_group.app_servers.min_size
}

output "asg_max_size" {
  description = "Maximum size of the ASG"
  value       = aws_autoscaling_group.app_servers.max_size
}

output "asg_desired_capacity" {
  description = "Desired capacity of the ASG (this will be ignored in Terraform after manual changes)"
  value       = aws_autoscaling_group.app_servers.desired_capacity
}

# ==============================
# Security Group Outputs
# ==============================

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "security_group_name" {
  description = "Name of the application security group"
  value       = aws_security_group.app_sg.name
}

# ==============================
# Region Information
# ==============================

output "current_region" {
  description = "Current AWS region being used"
  value       = data.aws_region.current.name
}

output "allowed_regions" {
  description = "List of allowed regions for deployment"
  value       = var.allowed_regions
}

# ==============================
# AMI Information
# ==============================

output "amazon_linux_ami_id" {
  description = "ID of the Amazon Linux 2 AMI being used"
  value       = data.aws_ami.amazon_linux_2.id
}

output "amazon_linux_ami_name" {
  description = "Name of the Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux_2.name
}

# ==============================
# DynamoDB Outputs
# ==============================

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table (multiple lifecycle rules example)"
  value       = aws_dynamodb_table.critical_app_data.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.critical_app_data.arn
}
