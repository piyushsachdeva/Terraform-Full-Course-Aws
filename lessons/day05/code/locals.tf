# Local Variables - Internal variables for reusability
locals {
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Terraform-Demo"
    Owner       = "DevOps-Team"
  }

  # Full bucket name with environment prefix
  full_bucket_name = "${var.environment}-${var.bucket_name}-${random_string.suffix.result}"
}

# Random string for unique bucket naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
