# Provider for the primary region (us-east-1)
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

# Provider for the secondary region (us-west-2)
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}
