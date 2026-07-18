# outputs.tf - All output values

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.tableau.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB for Route53 records"
  value       = aws_lb.tableau.zone_id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = try(aws_instance.bastion[0].public_ip, null)
}

output "bastion_ssh_command" {
  description = "SSH command to connect to Bastion"
  value       = try("ssh -i ${var.project_name}-key.pem ec2-user@${aws_instance.bastion[0].public_ip}", null)
}

output "tableau_server_private_ips" {
  description = "Private IPs of the Tableau server nodes"
  value       = aws_instance.tableau_server[*].private_ip
}

output "tableau_server_ids" {
  description = "Instance IDs of Tableau server nodes"
  value       = aws_instance.tableau_server[*].id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "tableau_sg_id" {
  description = "Security group ID for Tableau servers"
  value       = aws_security_group.tableau.id
}

output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "bastion_sg_id" {
  description = "Security group ID for Bastion"
  value       = aws_security_group.bastion.id
}

output "tableau_url" {
  description = "URL to access Tableau Server"
  value       = "https://${aws_lb.tableau.dns_name}"
}