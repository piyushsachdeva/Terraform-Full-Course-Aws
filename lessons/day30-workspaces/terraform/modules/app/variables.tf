variable "name_prefix" {
  description = "Workspace-specific prefix for AWS resource names."
  type        = string
}

variable "environment" {
  description = "Workspace name used for instance tags."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that contains the application."
  type        = string
}

variable "public_subnets" {
  description = "Public subnet IDs for the load balancer."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet IDs for the application instances."
  type        = list(string)
}

variable "ami_id" {
  description = "Ubuntu AMI ID for EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for this workspace."
  type        = string
}

variable "min_size" {
  description = "Minimum Auto Scaling Group size."
  type        = number
}

variable "desired_size" {
  description = "Desired Auto Scaling Group size."
  type        = number
}

variable "max_size" {
  description = "Maximum Auto Scaling Group size."
  type        = number
}

variable "app_image" {
  description = "Docker image to run on EC2."
  type        = string
}
