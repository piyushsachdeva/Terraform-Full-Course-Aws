variable "aws_region" {
  description = "AWS region for the application infrastructure. The S3 backend is configured for us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR range for this workspace's VPC. Keep it non-overlapping with connected networks."
  type        = string
  default     = "10.30.0.0/16"
}

variable "app_image" {
  description = "Docker Hub image to run as the application."
  type        = string
  default     = "itsbaivab/django-app"
}
