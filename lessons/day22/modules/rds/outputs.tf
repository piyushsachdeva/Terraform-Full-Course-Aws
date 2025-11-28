# RDS Module - Outputs

output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}
