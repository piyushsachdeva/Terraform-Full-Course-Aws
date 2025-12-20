output "db_password" {
  description = "Generated database password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.arn
}
