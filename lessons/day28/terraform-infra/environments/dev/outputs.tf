# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_ips
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.bastion.bastion_public_ip
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
}

# RDS Outputs
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

# Secrets Outputs
output "db_secret_name" {
  description = "Name of database credentials secret in Secrets Manager"
  value       = module.secrets.db_secret_name
}

# Docker Configuration Outputs
output "frontend_docker_image" {
  description = "Frontend Docker image name"
  value       = var.frontend_docker_image
}

output "backend_docker_image" {
  description = "Backend Docker image name"
  value       = var.backend_docker_image
}

# ASG Outputs
output "frontend_asg_name" {
  description = "Name of frontend Auto Scaling Group"
  value       = module.frontend_asg.asg_name
}

output "backend_asg_name" {
  description = "Name of backend Auto Scaling Group"
  value       = module.backend_asg.asg_name
}

# Quick Start Commands
output "helpful_commands" {
  description = "Helpful commands for working with this infrastructure"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════════════
                    Goal Tracker Infrastructure - Dev
    ═══════════════════════════════════════════════════════════════════
    
    🌐 Application URL:
       http://${module.alb.alb_dns_name}
    
    🔐 SSH to Bastion:
       ssh -i your-key.pem ec2-user@${module.bastion.bastion_public_ip}
    
    📦 Push Docker Images to Docker Hub:
       # Login to Docker Hub
       docker login
       
       # Build and push frontend
       cd ../../frontend
       docker build -t ${var.frontend_docker_image} .
       docker push ${var.frontend_docker_image}
       
       # Build and push backend
       cd ../backend
       docker build -t ${var.backend_docker_image} .
       docker push ${var.backend_docker_image}
    
    🔄 Trigger ASG Instance Refresh:
       aws autoscaling start-instance-refresh --auto-scaling-group-name ${module.frontend_asg.asg_name} --region ${var.region}
       aws autoscaling start-instance-refresh --auto-scaling-group-name ${module.backend_asg.asg_name} --region ${var.region}
    
    🗄️  Get Database Credentials:
       aws secretsmanager get-secret-value --secret-id ${module.secrets.db_secret_name} --region ${var.region} --query SecretString --output text | jq .
    
    📊 View Logs:
       # Frontend logs
       aws logs tail /aws/ec2/${var.environment}-${var.project}/frontend --follow
       
       # Backend logs
       aws logs tail /aws/ec2/${var.environment}-${var.project}/backend --follow
    
    ═══════════════════════════════════════════════════════════════════
  EOT
}
