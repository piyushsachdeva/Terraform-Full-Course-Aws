locals {
  common_tags = {
    environment = var.environment
    lob         = "banking"
    stage       = "alpha"
    managed_by  = "terraform"
  }

  # Combine common tags with resource-specific tags
  merged_tags = merge(local.common_tags, var.resource_tags)
}
