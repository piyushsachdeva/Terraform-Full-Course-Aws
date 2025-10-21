# String type
variable "environment" {
    type = string
    description = "the environment type"
    default = "dev"
}

variable "region" {
    type = string
    description = "the aws region"
    default = "us-east-1"
}

variable "instance_type" {
    type = string
    description = "the ec2 instance type"
    default = "t2.micro"
}

# Number type
variable "instance_count" {
    type = number
    description = "the number of ec2 instances to create"
    default = 1
}

variable "storage_size" {
    type = number
    description = "the storage size for ec2 instance in GB"
    default = 8
}

# Bool type
variable "enable_monitoring" {
    type = bool
    description = "enable detailed monitoring for ec2 instances"
    default = false
}

variable "associate_public_ip" {
    type = bool
    description = "associate public ip to ec2 instance"
    default = true
}

# List type - IMPORTANT: Allows duplicates, maintains order
variable "allowed_cidr_blocks" {
    type = list(string)
    description = "list of allowed cidr blocks for security group"
    default = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    # Access: var.allowed_cidr_blocks[0] = "10.0.0.0/8"
    # Can have duplicates: ["10.0.0.0/8", "10.0.0.0/8"] is valid
}

variable "allowed_instance_types" {
    type = list(string)
    description = "list of allowed ec2 instance types"
    default = ["t2.micro", "t2.small", "t3.micro"]
    # Order matters: index 0 = t2.micro, index 1 = t2.small
}

# Map type - IMPORTANT: Key-value pairs, keys must be unique
variable "instance_tags" {
    type = map(string)
    description = "tags to apply to the ec2 instances"
    default = {
        "Environment" = "dev"
        "Project" = "terraform-course"
        "Owner" = "devops-team"
    }
    # Access: var.instance_tags["Environment"] = "dev"
    # Keys are always strings, values must match the declared type
}

# Set type - IMPORTANT: No duplicates allowed, order doesn't matter
variable "availability_zones" {
    type = set(string)
    description = "set of availability zones (no duplicates)"
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
    # KEY DIFFERENCE FROM LIST:
    # - Automatically removes duplicates
    # - Order is not guaranteed
    # - Cannot access by index like set[0] - need to convert to list first
}

# Tuple type - IMPORTANT: Fixed length, each position has specific type
variable "network_config" {
    type = tuple([string, string, number])
    description = "Network configuration (VPC CIDR, subnet CIDR, port number)"
    default = ["10.0.0.0/16", "10.0.1.0/24", 80]
    # CRITICAL RULES:
    # - Position 0 must be string (VPC CIDR)
    # - Position 1 must be string (subnet CIDR)  
    # - Position 2 must be number (port)
    # - Cannot add/remove elements - length is fixed
    # Access: var.network_config[0], var.network_config[1], var.network_config[2]
}

# Object type - IMPORTANT: Named attributes with specific types
variable "server_config" {
    type = object({
        name = string
        instance_type = string
        monitoring = bool
        storage_gb = number
        backup_enabled = bool
    })
    description = "Complete server configuration object"
    default = {
        name = "web-server"
        instance_type = "t2.micro"
        monitoring = true
        storage_gb = 20
        backup_enabled = false
    }
    # KEY BENEFITS:
    # - Self-documenting structure
    # - Type safety for each attribute
    # - Access: var.server_config.name, var.server_config.monitoring
    # - All attributes must be provided (unless optional)
}

