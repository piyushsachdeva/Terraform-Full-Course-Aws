# Outputs for EKS Cluster with Custom Modules

# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_gateway_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# IAM Outputs
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.iam.cluster_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the node groups"
  value       = module.iam.node_group_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

# EKS Outputs
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = module.eks.node_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "kms_key_arn" {
  description = "KMS key ARN used for cluster encryption"
  value       = module.eks.kms_key_arn
}

# Secrets Manager Outputs (if enabled)
output "secrets_kms_key_arn" {
  description = "KMS key ARN used for secrets encryption"
  value       = var.enable_db_secret || var.enable_api_secret || var.enable_app_config_secret ? module.secrets_manager.kms_key_arn : ""
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = var.enable_db_secret ? module.secrets_manager.db_secret_arn : ""
}

output "api_secret_arn" {
  description = "ARN of the API keys secret"
  value       = var.enable_api_secret ? module.secrets_manager.api_secret_arn : ""
}

output "app_config_secret_arn" {
  description = "ARN of the application config secret"
  value       = var.enable_app_config_secret ? module.secrets_manager.app_config_secret_arn : ""
}

# Convenience Outputs
output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}
