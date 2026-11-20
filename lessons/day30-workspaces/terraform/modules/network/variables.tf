variable "name_prefix" {
  description = "Workspace-specific prefix for AWS resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "azs" {
  description = "Two availability zones for the public and private subnets."
  type        = list(string)

  validation {
    condition     = length(var.azs) == 2
    error_message = "Provide exactly two availability zones."
  }
}
