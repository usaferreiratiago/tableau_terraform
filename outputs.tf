output "instance_id" {
  description = "EC2 instance ID of the Tableau Server host."
  value       = module.tableau_ec2.instance_id
}

output "public_ip" {
  description = "Public IP address of the Tableau Server host."
  value       = module.tableau_ec2.public_ip
}

output "private_ip" {
  description = "Private IP address of the Tableau Server host."
  value       = module.tableau_ec2.private_ip
}

output "tableau_server_url" {
  description = "URL for the Tableau Server web UI."
  value       = "https://${module.tableau_ec2.public_ip}"
}

output "tsm_admin_url" {
  description = "URL for the TSM (Tableau Services Manager) administration UI."
  value       = "https://${module.tableau_ec2.public_ip}:8850"
}

output "ssh_private_key_path" {
  description = "Path to the generated private key file."
  value       = "${path.module}/${var.project_name}-key.pem"
}

output "ssh_connection_command" {
  description = "Convenience SSH command to connect to the instance."
  value       = "ssh -i ${var.project_name}-key.pem ubuntu@${module.tableau_ec2.public_ip}"
}



variable "project_name" {
  description = "Project name used to construct generated artifact names."
  type        = string
}
