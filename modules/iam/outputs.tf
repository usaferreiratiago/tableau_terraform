output "instance_profile_name" {
  value = aws_iam_instance_profile.tableau.name
}

output "role_name" {
  value = aws_iam_role.tableau_server.name
}