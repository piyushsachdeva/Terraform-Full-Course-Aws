output "upload_bucket_name" {
  description = "S3 bucket for uploading images (SOURCE)"
  value       = aws_s3_bucket.upload_bucket.id
}

output "processed_bucket_name" {
  description = "S3 bucket for processed images (DESTINATION)"
  value       = aws_s3_bucket.processed_bucket.id
}

output "lambda_function_name" {
  description = "Lambda function name for image processing"
  value       = aws_lambda_function.image_processor.function_name
}

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "upload_command_example" {
  description = "Example command to upload an image"
  value       = "aws s3 cp your-image.jpg s3://${aws_s3_bucket.upload_bucket.id}/"
}
