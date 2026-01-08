output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "internal_alb_sg_id" {
  description = "ID of the Internal ALB security group"
  value       = aws_security_group.internal_alb.id
}

output "bastion_sg_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

output "frontend_sg_id" {
  description = "ID of the Frontend security group"
  value       = aws_security_group.frontend.id
}

output "backend_sg_id" {
  description = "ID of the Backend security group"
  value       = aws_security_group.backend.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}
