output "efs_dns_name" {
  description = "The DNS name to mount the EFS filesystem"
  value       = aws_efs_file_system.tableau_efs.dns_name
}

output "efs_id" {
  description = "The EFS File System ID"
  value       = aws_efs_file_system.tableau_efs.id
}