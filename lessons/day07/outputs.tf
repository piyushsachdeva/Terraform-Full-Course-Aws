# VPC outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet outputs
output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.internal.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.internal.cidr_block
}

# Security Group outputs
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}

# EC2 Instance outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = aws_instance.main.instance_type
}

# Outputs demonstrating type usage
output "environment_info" {
  description = "Environment information from string type variable"
  value = {
    name         = var.environment
    type         = "string"
    is_staging   = var.environment == "staging"
    display_name = upper(var.environment)
  }
}

output "storage_info" {
  description = "Storage information from number type variable"
  value = {
    disk_size_gb = var.storage_disk
    disk_size_mb = var.storage_disk * 1024
    type         = "number"
  }
}

output "deletion_policy" {
  description = "Deletion policy from boolean type variable"
  value = {
    delete_on_termination = var.is_delete
    policy_text           = var.is_delete ? "Volumes will be deleted" : "Volumes will be retained"
    type                  = "bool"
  }
}

output "allowed_regions" {
  description = "Allowed regions from list type variable"
  value = {
    regions      = var.allowed_locations
    region_count = length(var.allowed_locations)
    primary      = var.allowed_locations[0]
    type         = "list(string)"
  }
}

output "tags_info" {
  description = "Tags from map type variable"
  value = {
    tags       = var.resource_tags
    tag_count  = length(keys(var.resource_tags))
    tag_keys   = keys(var.resource_tags)
    tag_values = values(var.resource_tags)
    type       = "map(string)"
  }
}

output "network_configuration" {
  description = "Network configuration from tuple type variable"
  value = {
    tuple_value   = var.network_config
    vpc_cidr      = element(var.network_config, 0)
    subnet_prefix = element(var.network_config, 1)
    cidr_bits     = element(var.network_config, 2)
    subnet_full   = "${element(var.network_config, 1)}/${element(var.network_config, 2)}"
    type          = "tuple([string, string, number])"
  }
}

output "instance_types_info" {
  description = "Instance types from list type variable"
  value = {
    allowed_types = var.allowed_instance_types
    count         = length(var.allowed_instance_types)
    selected      = var.allowed_instance_types[0]
    type          = "list(string)"
  }
}

output "vm_configuration" {
  description = "VM configuration from object type variable"
  value = {
    config        = var.vm_config
    instance_type = var.vm_config.instance_type
    ami_id        = var.vm_config.ami_id
    monitoring    = var.vm_config.monitoring
    type          = "object"
  }
  sensitive = false
}

output "all_resource_tags" {
  description = "All tags applied to resources (merged common_tags + resource_tags)"
  value       = local.common_tags
}
