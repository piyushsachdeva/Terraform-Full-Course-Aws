# IAM Module Outputs

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.name
}

output "node_group_role_arn" {
  description = "ARN of the node group IAM role"
  value       = aws_iam_role.node_group.arn
}

output "node_group_role_name" {
  description = "Name of the node group IAM role"
  value       = aws_iam_role.node_group.name
}
