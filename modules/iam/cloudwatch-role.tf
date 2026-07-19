resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.tableau_server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}