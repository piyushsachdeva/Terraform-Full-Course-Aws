variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}
