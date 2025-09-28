# Simple S3 Bucket using all three types of variables
resource "aws_s3_bucket" "demo" {
  bucket = local.full_bucket_name # Local variable (computed)

  tags = local.common_tags # Local variable (tags)
}
