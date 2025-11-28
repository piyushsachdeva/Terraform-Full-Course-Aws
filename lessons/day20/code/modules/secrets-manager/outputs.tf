# Secrets Manager Module Outputs

output "kms_key_id" {
  description = "ID of the KMS key used for secrets encryption"
  value       = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? aws_kms_key.secrets[0].id : ""
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for secrets encryption"
  value       = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? aws_kms_key.secrets[0].arn : ""
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_credentials[0].arn : ""
}

output "db_secret_name" {
  description = "Name of the database credentials secret"
  value       = var.create_db_secret ? aws_secretsmanager_secret.db_credentials[0].name : ""
}

output "api_secret_arn" {
  description = "ARN of the API keys secret"
  value       = var.create_api_secret ? aws_secretsmanager_secret.api_keys[0].arn : ""
}

output "api_secret_name" {
  description = "Name of the API keys secret"
  value       = var.create_api_secret ? aws_secretsmanager_secret.api_keys[0].name : ""
}

output "app_config_secret_arn" {
  description = "ARN of the application config secret"
  value       = var.create_app_config_secret ? aws_secretsmanager_secret.app_config[0].arn : ""
}

output "app_config_secret_name" {
  description = "Name of the application config secret"
  value       = var.create_app_config_secret ? aws_secretsmanager_secret.app_config[0].name : ""
}

output "read_secrets_policy_arn" {
  description = "ARN of the IAM policy for reading secrets"
  value       = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? aws_iam_policy.read_secrets[0].arn : ""
}

output "read_secrets_policy_name" {
  description = "Name of the IAM policy for reading secrets"
  value       = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? aws_iam_policy.read_secrets[0].name : ""
}
