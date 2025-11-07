output "vpc_id" {
  value = aws_vpc.shared.id
}

output "subnet_id" {
  value = aws_subnet.shared.id
}

output "vpc_name" {
  value = aws_vpc.shared.tags["Name"]
}

output "subnet_name" {
  value = aws_subnet.shared.tags["Name"]
}
