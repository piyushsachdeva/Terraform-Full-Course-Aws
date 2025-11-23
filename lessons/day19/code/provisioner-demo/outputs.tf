output "instance_id" {
  description = "ID of the demo EC2 instance"
  value       = aws_instance.demo.id
}

output "public_ip" {
  description = "Public IP of the demo EC2 instance"
  value       = aws_instance.demo.public_ip
}
