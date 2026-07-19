output "instance_profile_name" {
  description = "The IAM instance profile name for the Tableau EC2"
  value       = aws_iam_instance_profile.tableau_server.name
}

output "role_name" {
  value = aws_iam_role.tableau_server.name
}