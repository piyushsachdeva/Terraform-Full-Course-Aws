# Secrets Manager Module Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "create_db_secret" {
  description = "Create database credentials secret"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = ""
}

variable "create_api_secret" {
  description = "Create API keys secret"
  type        = bool
  default     = false
}

variable "api_key" {
  description = "API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_secret" {
  description = "API secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_app_config_secret" {
  description = "Create application config secret"
  type        = bool
  default     = false
}

variable "app_config" {
  description = "Application configuration as a map"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
