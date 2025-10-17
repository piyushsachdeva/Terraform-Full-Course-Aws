# ==============================
# Data Sources
# ==============================

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get current AWS region
data "aws_region" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================
# Example 1: create_before_destroy
# Use Case: EC2 instance that needs zero downtime during updates
# ==============================

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tags = merge(
    var.resource_tags,
    {
      Name = var.instance_name
      Demo = "create_before_destroy"
    }
  )

  # Lifecycle Rule: Create new instance before destroying the old one
  # This ensures zero downtime during instance updates (e.g., changing AMI or instance type)
  lifecycle {
    create_before_destroy = true
  }
}

# ==============================
# Example 2: prevent_destroy
# Use Case: Critical S3 bucket that should never be accidentally deleted
# ==============================

resource "aws_s3_bucket" "critical_data" {
  bucket = "my-critical-production-data-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name       = "Critical Production Data Bucket"
      Demo       = "prevent_destroy"
      DataType   = "Critical"
      Compliance = "Required"
    }
  )

  # Lifecycle Rule: Prevent accidental deletion of this bucket
  # Terraform will throw an error if you try to destroy this resource
  # To delete: Comment out prevent_destroy first, then run terraform apply
  lifecycle {
    # prevent_destroy = true  # COMMENTED OUT TO ALLOW DESTRUCTION
  }
}

# Enable versioning on the critical bucket
resource "aws_s3_bucket_versioning" "critical_data" {
  bucket = aws_s3_bucket.critical_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ==============================
# Example 3: ignore_changes
# Use Case: Auto Scaling Group where capacity is managed externally
# ==============================

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "app_server" {
  name_prefix   = "app-server-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.resource_tags,
      {
        Name = "App Server from ASG"
        Demo = "ignore_changes"
      }
    )
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_servers" {
  name               = "app-servers-asg"
  min_size           = 1
  max_size           = 5
  desired_capacity   = 2
  health_check_type  = "EC2"
  availability_zones = data.aws_availability_zones.available.names

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "App Server ASG"
    propagate_at_launch = true
  }

  tag {
    key                 = "Demo"
    value               = "ignore_changes"
    propagate_at_launch = false
  }

  # Lifecycle Rule: Ignore changes to desired_capacity
  # This is useful when auto-scaling policies or external systems modify capacity
  # Terraform won't try to revert capacity changes made outside of Terraform
  lifecycle {
    ignore_changes = [
      desired_capacity,
      # Also ignore load_balancers if added later by other processes
    ]
  }
}

# ==============================
# Example 4: precondition
# Use Case: Ensure we're deploying in an allowed region
# ==============================

resource "aws_s3_bucket" "regional_validation" {
  bucket = "validated-region-bucket-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name = "Region Validated Bucket"
      Demo = "precondition"
    }
  )

  # Lifecycle Rule: Validate region before creating resource
  # This prevents resource creation in unauthorized regions
  lifecycle {
    precondition {
      condition     = contains(var.allowed_regions, data.aws_region.current.name)
      error_message = "ERROR: This resource can only be created in allowed regions: ${join(", ", var.allowed_regions)}. Current region: ${data.aws_region.current.name}"
    }
  }
}

# ==============================
# Example 5: postcondition
# Use Case: Ensure S3 bucket has required tags after creation
# ==============================

resource "aws_s3_bucket" "compliance_bucket" {
  bucket = "compliance-bucket-${var.environment}-${data.aws_region.current.name}"

  tags = merge(
    var.resource_tags,
    {
      Name       = "Compliance Validated Bucket"
      Demo       = "postcondition"
      Compliance = "SOC2"
    }
  )

  # Lifecycle Rule: Validate bucket has required tags after creation
  # This ensures compliance with organizational tagging policies
  lifecycle {
    postcondition {
      condition     = contains(keys(self.tags), "Compliance")
      error_message = "ERROR: Bucket must have a 'Compliance' tag for audit purposes!"
    }

    postcondition {
      condition     = contains(keys(self.tags), "Environment")
      error_message = "ERROR: Bucket must have an 'Environment' tag!"
    }
  }
}

# ==============================
# Example 6: replace_triggered_by
# Use Case: Replace EC2 instances when security group changes
# ==============================

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for application servers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.resource_tags,
    {
      Name = "App Security Group"
      Demo = "replace_triggered_by"
    }
  )
}

# EC2 Instance that gets replaced when security group changes
resource "aws_instance" "app_with_sg" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = merge(
    var.resource_tags,
    {
      Name = "App Instance with Security Group"
      Demo = "replace_triggered_by"
    }
  )

  # Lifecycle Rule: Replace instance when security group changes
  # This ensures the instance is recreated with new security rules
  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg.id
    ]
  }
}

# ==============================
# Example 7: Multiple S3 Buckets with create_before_destroy
# Use Case: Managing multiple buckets from a set
# ==============================

resource "aws_s3_bucket" "app_buckets" {
  for_each = var.bucket_names

  bucket = "${each.value}-${var.environment}"

  tags = merge(
    var.resource_tags,
    {
      Name   = each.value
      Demo   = "for_each_with_lifecycle"
      Bucket = each.key
    }
  )

  # Lifecycle Rule: Create new bucket before destroying old one
  # Useful when renaming buckets or migrating data
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore ACL changes if managed by another process
      # acl,
    ]
  }
}

# ==============================
# Example 8: Combining Multiple Lifecycle Rules
# Use Case: DynamoDB table with comprehensive protections (SIMPLE EXAMPLE)
# ==============================

# This example shows how to combine multiple lifecycle rules on a single resource
# DynamoDB is used here because it's simple and doesn't require VPC setup

resource "aws_dynamodb_table" "critical_app_data" {
  name         = "${var.environment}-app-data-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.resource_tags,
    {
      Name        = "Critical Application Data"
      Demo        = "multiple_lifecycle_rules"
      DataType    = "Critical"
      Environment = var.environment
    }
  )

  # Multiple Lifecycle Rules Combined for Production Protection
  lifecycle {
    # Rule 1: Prevent accidental deletion
    # This protects the table from being destroyed accidentally
    # prevent_destroy = true  # COMMENTED OUT TO ALLOW DESTRUCTION

    # Rule 2: Create new resource before destroying old one
    # Ensures zero downtime if table needs to be recreated
    create_before_destroy = true

    # Rule 3: Ignore changes to certain attributes
    # Allow AWS to manage read/write capacity for auto-scaling
    ignore_changes = [
      # Ignore read/write capacity if using auto-scaling
      # read_capacity,
      # write_capacity,
    ]

    # Rule 4: Validate before creation
    precondition {
      condition     = contains(keys(var.resource_tags), "Environment")
      error_message = "Critical table must have Environment tag for compliance!"
    }

    # Rule 5: Validate after creation
    postcondition {
      condition     = self.billing_mode == "PAY_PER_REQUEST" || self.billing_mode == "PROVISIONED"
      error_message = "Billing mode must be either PAY_PER_REQUEST or PROVISIONED!"
    }
  }
}

# ==============================
# Note: RDS Example (Too Complex for Simple Demo)
# ==============================
# RDS requires VPC, subnets, security groups, etc.
# For a simple lifecycle demo, the above DynamoDB example is better
# If you need RDS lifecycle examples, set up VPC resources first
# 
# See the documentation for production RDS patterns with lifecycle rules
