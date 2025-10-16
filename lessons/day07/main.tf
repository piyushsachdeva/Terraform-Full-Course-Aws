# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = element(var.network_config, 0)
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

# Create Subnet
resource "aws_subnet" "internal" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${element(var.network_config, 1)}/${element(var.network_config, 2)}"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-subnet"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-rt"
    }
  )
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.main.id
}

# Create Security Group
resource "aws_security_group" "main" {
  name        = "${var.environment}-sg"
  description = "Security group for ${var.environment} environment"
  vpc_id      = aws_vpc.main.id

  # Dynamic ingress rules based on list
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-sg"
    }
  )
}

# Create Network Interface
resource "aws_network_interface" "main" {
  subnet_id       = aws_subnet.internal.id
  security_groups = [aws_security_group.main.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-nic"
    }
  )
}

# Create EC2 Instance
resource "aws_instance" "main" {
  ami           = var.vm_config.ami_id
  instance_type = var.allowed_instance_types[0] # Use first allowed instance type
  key_name      = var.vm_config.key_name != "" ? var.vm_config.key_name : null
  monitoring    = var.vm_config.monitoring
  user_data     = var.vm_config.user_data != "" ? var.vm_config.user_data : null

  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = var.storage_disk
    volume_type           = "gp3"
    delete_on_termination = var.is_delete
    encrypted             = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.environment}-root-volume"
      }
    )
  }

  tags = merge(
    local.common_tags,
    var.resource_tags,
    {
      Name = "${var.environment}-ec2-instance"
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [var.allowed_locations[0]]
  }
}
