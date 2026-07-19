resource "aws_iam_instance_profile" "tableau" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.tableau_server.name
}