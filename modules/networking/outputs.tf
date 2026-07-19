output "vpc_id" {

  description = "VPC ID"

  value = aws_vpc.this.id

}

output "vpc_cidr" {

  value = aws_vpc.this.cidr_block

}

output "internet_gateway_id" {

  value = aws_internet_gateway.this.id

}

output "public_subnet_ids" {

  value = aws_subnet.public[*].id

}

output "private_subnet_ids" {

  value = aws_subnet.private[*].id

}

output "public_route_table_id" {

  value = aws_route_table.public.id

}

output "private_route_table_id" {

  value = aws_route_table.private.id

}

output "nat_gateway_id" {

  value = try(aws_nat_gateway.this[0].id, null)

}

output "availability_zones" {

  value = var.availability_zones

}