# Variables for EKS Cluster Configuration with Custom Modules

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "day20-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# Secrets Manager Variables (Optional)
variable "enable_db_secret" {
  description = "Enable database credentials secret"
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

variable "enable_api_secret" {
  description = "Enable API keys secret"
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

variable "enable_app_config_secret" {
  description = "Enable application config secret"
  type        = bool
  default     = false
}

variable "app_config" {
  description = "Application configuration as a map"
  type        = map(string)
  default     = {}
  sensitive   = true
}
