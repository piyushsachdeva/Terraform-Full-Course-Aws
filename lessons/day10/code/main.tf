# ==============================================================================
# EXAMPLE 1: CONDITIONAL EXPRESSIONS
# ==============================================================================
# Uncomment the block below to test conditional expressions
# This example shows how to choose instance type based on environment
# - If environment is "prod", use t3.large
# - Otherwise, use t2.micro
# ==============================================================================

resource "aws_instance" "conditional_example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"

  tags = {
    Name = "conditional-instance-${var.environment}"
  }
}

# ==============================================================================
# EXAMPLE 2: DYNAMIC BLOCKS
# ==============================================================================
# Uncomment the block below to test dynamic blocks
# This example creates multiple security group rules from a list variable
# - No need to repeat ingress blocks manually
# - Add/remove rules by editing the ingress_rules variable
# ==============================================================================

# resource "aws_security_group" "dynamic_sg" {
#   name        = "dynamic-sg-${var.environment}"
#   description = "Security group with dynamic rules"
  
#   # Dynamic block creates multiple ingress rules from a list
#   dynamic "ingress" {
#     for_each = var.ingress_rules
#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#       description = ingress.value.description
#     }
#   }
  
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
#   tags = {
#     Name = "dynamic-sg-${var.environment}"
#   }
# }

# ==============================================================================
# EXAMPLE 3: SPLAT EXPRESSIONS
# ==============================================================================
# Uncomment the blocks below to test splat expressions
# This example creates multiple instances and uses splat [*] to extract values
# - Creates 'instance_count' number of instances
# - Extracts all IDs and IPs in a single expression
# ==============================================================================

# resource "aws_instance" "splat_example" {
#   count = var.instance_count
  
#   ami           = data.aws_ami.amazon_linux.id
#   instance_type = "t2.micro"
  
#   tags = {
#     Name = "instance-${count.index + 1}"
#   }
# }

# # Use splat expressions to extract values from all instances
# locals {
#   # Get all instance IDs in one line using [*]
#   all_instance_ids = aws_instance.splat_example[*].id
  
#   # Get all private IPs using [*]
#   all_private_ips = aws_instance.splat_example[*].private_ip
# }

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
