resource "aws_iam_policy" "secrets_manager" {
  name        = "${local.name_prefix}-secrets-policy"
  description = "Access to Tableau secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Effect   = "Allow"
      Resource = "*" # Restrict to specific ARNs in production
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.tableau_server.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}