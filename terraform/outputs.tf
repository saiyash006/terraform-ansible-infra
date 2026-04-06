output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}

output "public_ips" {
  description = "Public IPs of web instances"
  value       = aws_instance.web[*].public_ip
}
