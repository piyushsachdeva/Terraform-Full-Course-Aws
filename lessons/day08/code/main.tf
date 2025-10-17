# =============================================================================
# Day 08: Meta-Arguments in Terraform (count and for_each)
# =============================================================================
# This file demonstrates the use of meta-arguments:
# 1. count - Creates multiple instances using index-based iteration
# 2. for_each - Creates multiple instances using map/set iteration
# =============================================================================

# -----------------------------------------------------------------------------
# Example 1: Using COUNT meta-argument with S3 buckets
# -----------------------------------------------------------------------------
# count is useful when you want to create multiple identical resources
# Access individual instances using count.index

resource "aws_s3_bucket" "example_count" {
  count = length(var.s3_bucket_names)

  bucket = var.s3_bucket_names[count.index]

  tags = {
    Name        = var.s3_bucket_names[count.index]
    Environment = var.environment
    Index       = count.index
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Example 2: Using FOR_EACH meta-argument with S3 buckets
# -----------------------------------------------------------------------------
# for_each is useful when you want to create resources from a map or set
# Access individual instances using each.key and each.value
# Note: for_each requires a map or set, not a list

resource "aws_s3_bucket" "example_foreach" {
  for_each = var.s3_bucket_set

  bucket = each.value

  tags = {
    Name        = each.value
    Environment = var.environment
    BucketType  = "foreach-example"
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Example 3: DEPENDS_ON meta-argument
# -----------------------------------------------------------------------------
# depends_on is used to explicitly specify dependencies between resources
# Terraform automatically handles most dependencies, but sometimes you need explicit control

# First, create a bucket that will be used as a dependency
resource "aws_s3_bucket" "primary" {
  bucket = "tf-day08-primary-${var.environment}-20251017"

  tags = {
    Name        = "Primary Bucket"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# This bucket explicitly depends on the primary bucket
resource "aws_s3_bucket" "dependent" {
  bucket = "tf-day08-dependent-${var.environment}-20251017"

  # Explicit dependency - this will be created AFTER primary bucket
  depends_on = [aws_s3_bucket.primary]

  tags = {
    Name        = "Dependent Bucket"
    Environment = var.environment
    DependsOn   = "primary-bucket"
    ManagedBy   = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Example 4: LIFECYCLE meta-argument
# -----------------------------------------------------------------------------
# lifecycle controls how Terraform handles resource creation/destruction
# Common use cases: prevent_destroy, create_before_destroy, ignore_changes

resource "aws_s3_bucket" "lifecycle_example" {
  bucket = "tf-day08-lifecycle-${var.environment}-20251017"

  # Lifecycle rules
  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false # Set to true in production to protect critical resources

    # Create new resource before destroying old one
    create_before_destroy = true

    # Ignore changes to specific attributes
    ignore_changes = [
      tags["CreatedDate"], # Ignore changes to this specific tag
    ]
  }

  tags = {
    Name        = "Lifecycle Example"
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedDate = "2025-10-17"
  }
}


