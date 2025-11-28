# Custom Secrets Manager Module

# KMS Key for Secrets Manager encryption (only created if at least one secret is enabled)
resource "aws_kms_key" "secrets" {
  count                   = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? 1 : 0
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-secrets-kms"
    }
  )
}

resource "aws_kms_alias" "secrets" {
  count         = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? 1 : 0
  name          = "alias/${var.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}

# Secrets Manager - Database Credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  count                   = var.create_db_secret ? 1 : 0
  name                    = "${var.name_prefix}-db-credentials"
  description             = "Database credentials for ${var.name_prefix}"
  kms_key_id              = aws_kms_key.secrets[0].id
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-credentials"
      Type = "database"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count     = var.create_db_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = var.db_engine
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}

# Secrets Manager - API Keys
resource "aws_secretsmanager_secret" "api_keys" {
  count                   = var.create_api_secret ? 1 : 0
  name                    = "${var.name_prefix}-api-keys"
  description             = "API keys for ${var.name_prefix}"
  kms_key_id              = aws_kms_key.secrets[0].id
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-api-keys"
      Type = "api"
    }
  )
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  count     = var.create_api_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.api_keys[0].id
  secret_string = jsonencode({
    api_key    = var.api_key
    api_secret = var.api_secret
  })
}

# Secrets Manager - Application Config
resource "aws_secretsmanager_secret" "app_config" {
  count                   = var.create_app_config_secret ? 1 : 0
  name                    = "${var.name_prefix}-app-config"
  description             = "Application configuration for ${var.name_prefix}"
  kms_key_id              = aws_kms_key.secrets[0].id
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-app-config"
      Type = "application"
    }
  )
}

resource "aws_secretsmanager_secret_version" "app_config" {
  count         = var.create_app_config_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.app_config[0].id
  secret_string = jsonencode(var.app_config)
}

# IAM Policy for reading secrets (only created if at least one secret is enabled)
resource "aws_iam_policy" "read_secrets" {
  count       = var.create_db_secret || var.create_api_secret || var.create_app_config_secret ? 1 : 0
  name_prefix = "${var.name_prefix}-read-secrets-"
  description = "Allow reading secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = concat(
          var.create_db_secret ? [aws_secretsmanager_secret.db_credentials[0].arn] : [],
          var.create_api_secret ? [aws_secretsmanager_secret.api_keys[0].arn] : [],
          var.create_app_config_secret ? [aws_secretsmanager_secret.app_config[0].arn] : []
        )
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.secrets[0].arn]
      }
    ]
  })

  tags = var.tags
}
