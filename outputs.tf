output "vpc_id" {
  description = "Xilution VPC ID"
  value = aws_vpc.xilution_vpc.id
}

output "public_subnet_1" {
  description = "Xilution Public Subnet 1"
  value = aws_subnet.xilution_public_subnet_1
}

output "public_subnet_2" {
  description = "Xilution Public Subnet 2"
  value = aws_subnet.xilution_public_subnet_2
}
