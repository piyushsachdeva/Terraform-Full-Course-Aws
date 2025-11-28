# Day 22 - RDS Database Mini Project
# Outputs Configuration

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

# EC2 Outputs
output "web_server_public_ip" {
  description = "Public IP address of the web server"
  value       = module.ec2.public_ip
}

output "web_server_public_dns" {
  description = "Public DNS of the web server"
  value       = module.ec2.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.ec2.public_ip}"
}

# RDS Outputs
output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.rds.db_port
}

output "database_name" {
  description = "Name of the database"
  value       = module.rds.db_name
}
