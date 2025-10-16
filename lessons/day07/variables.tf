# String type
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, production)"
  default     = "staging"
}

# Number type
variable "storage_disk" {
  type        = number
  description = "Root volume size in GB for EC2 instance"
  default     = 20
}

# Boolean type
variable "is_delete" {
  type        = bool
  description = "Delete EBS volume on instance termination"
  default     = true
}

# List type
variable "allowed_locations" {
  type        = list(string)
  description = "List of allowed AWS regions"
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

# Map type
variable "resource_tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    "environment" = "staging"
    "managed_by"  = "terraform"
    "department"  = "engineering"
  }
}

# Tuple type - [vpc_cidr, subnet_cidr, cidr_bits]
variable "network_config" {
  type        = tuple([string, string, number])
  description = "Network configuration: [VPC CIDR, Subnet CIDR prefix, CIDR bits]"
  default     = ["10.0.0.0/16", "10.0.1.0", 24]
}

# List of strings
variable "allowed_instance_types" {
  type        = list(string)
  description = "Allowed EC2 instance types"
  default     = ["t3.micro", "t3.small", "t3.medium"]
}

# Object type for EC2 instance configuration
variable "vm_config" {
  type = object({
    instance_type = string
    ami_id        = string
    key_name      = string
    monitoring    = bool
    user_data     = string
  })
  description = "EC2 instance configuration"
  default = {
    instance_type = "t3.micro"
    ami_id        = "ami-0c02fb55956c7d316" # Amazon Linux 2023 (us-east-1)
    key_name      = ""                      # Leave empty if no key pair
    monitoring    = false
    user_data     = ""
  }
}

# Additional variable for VPC ID (if using existing VPC)
variable "vpc_id" {
  type        = string
  description = "VPC ID (leave empty to create new VPC)"
  default     = ""
}

# Security group ingress rules
variable "ingress_ports" {
  type        = list(number)
  description = "List of ingress ports to allow"
  default     = [22, 80, 443]
}
