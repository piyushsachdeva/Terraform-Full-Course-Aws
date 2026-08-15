output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "frontend_subnet_ids" {
  description = "List of frontend private subnet IDs"
  value       = aws_subnet.frontend[*].id
}

output "backend_subnet_ids" {
  description = "List of backend private subnet IDs"
  value       = aws_subnet.backend[*].id
}

output "database_subnet_ids" {
  description = "List of database isolated subnet IDs"
  value       = aws_subnet.database[*].id
}

output "nat_gateway_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
