# ------------------------------------------------------------------------------
# IAM Policy Outputs
# ------------------------------------------------------------------------------

output "mfa_delete_policy_arn" {
  description = "ARN of the MFA delete policy"
  value       = aws_iam_policy.mfa_delete_policy.arn
}

output "s3_encryption_transit_policy_arn" {
  description = "ARN of the S3 encryption in transit policy"
  value       = aws_iam_policy.enforce_s3_encryption_transit.arn
}

output "require_tags_policy_arn" {
  description = "ARN of the require tags policy"
  value       = aws_iam_policy.require_tags_policy.arn
}

output "demo_user_name" {
  description = "Name of the demo IAM user"
  value       = aws_iam_user.demo_user.name
}

output "demo_user_arn" {
  description = "ARN of the demo IAM user"
  value       = aws_iam_user.demo_user.arn
}

# ------------------------------------------------------------------------------
# S3 and Config Outputs
# ------------------------------------------------------------------------------

output "config_bucket_name" {
  description = "Name of the S3 bucket used for AWS Config"
  value       = aws_s3_bucket.config_bucket.id
}

output "config_bucket_arn" {
  description = "ARN of the Config S3 bucket"
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_recorder_status" {
  description = "Status of the AWS Config recorder"
  value       = aws_config_configuration_recorder_status.main.is_enabled
}

# ------------------------------------------------------------------------------
# Config Rules Outputs
# ------------------------------------------------------------------------------

output "config_rules" {
  description = "List of all Config rule names"
  value = [
    aws_config_config_rule.s3_public_write_prohibited.name,
    aws_config_config_rule.s3_encryption.name,
    aws_config_config_rule.s3_public_read_prohibited.name,
    aws_config_config_rule.ebs_encryption.name,
    aws_config_config_rule.required_tags.name,
    aws_config_config_rule.root_mfa_enabled.name
  ]
}

output "compliance_dashboard_info" {
  description = "Information about accessing the compliance dashboard"
  value       = "Visit AWS Config Console in ${var.aws_region} to view compliance status"
}
