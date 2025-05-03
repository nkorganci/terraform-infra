output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
  description = "List of public subnet IDs"
}
output "private_subnet_ids" {
  value = values(aws_subnet.private)[*].id
}
