# Security Groups Module - Outputs

output "web_sg_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db.id
}
