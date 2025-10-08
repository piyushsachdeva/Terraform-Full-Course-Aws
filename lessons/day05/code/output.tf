# Output Variables - Values returned after Terraform apply
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo.arn
}

output "environment" {
  description = "Environment from input variable"
  value       = var.environment
}

output "tags" {
  description = "Tags from local variable"
  value       = local.common_tags
}
