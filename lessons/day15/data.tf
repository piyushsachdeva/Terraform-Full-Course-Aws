# Data Sources for VPC Peering Demo

# Data source to get available AZs in Primary region
data "aws_availability_zones" "primary" {
  provider = aws.primary
  state    = "available"
}

# Data source to get available AZs in Secondary region
data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}

# Data source for Primary region AMI (Amazon Linux 2)
data "aws_ami" "primary_ami" {
  provider    = aws.primary
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

# Data source for Secondary region AMI (Amazon Linux 2)
data "aws_ami" "secondary_ami" {
  provider    = aws.secondary
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
