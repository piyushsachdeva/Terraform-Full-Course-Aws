# ==============================
# Local Values
# ==============================

locals {
  # Common tags that will be merged with resource-specific tags
  common_tags = {
    Environment = var.environment
    Team        = "DevOps"
    ManagedBy   = "Terraform"
    Project     = "Lifecycle-Demo"
  }

  # Timestamp for unique naming
  timestamp = formatdate("YYYY-MM-DD", timestamp())

  # Environment-specific settings
  env_config = {
    dev = {
      instance_type = "t2.micro"
      multi_az      = false
    }
    staging = {
      instance_type = "t2.small"
      multi_az      = false
    }
    prod = {
      instance_type = "t2.medium"
      multi_az      = true
    }
  }

  # Get configuration for current environment
  current_env_config = lookup(local.env_config, var.environment, local.env_config["dev"])

  # Bucket naming convention
  bucket_prefix = "${var.environment}-lifecycle-demo"

  # Formatted region name for bucket naming
  region_short = replace(data.aws_region.current.name, "-", "")

  # Availability zones count
  az_count = length(data.aws_availability_zones.available.names)
}
