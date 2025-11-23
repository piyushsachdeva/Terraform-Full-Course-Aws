variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair (must already exist in the chosen region)"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file for SSH (used by remote provisioners)"
  type        = string
}

variable "ssh_user" {
  description = "SSH username for the AMI (default for Ubuntu is 'ubuntu')"
  type        = string
  default     = "ubuntu"
}
