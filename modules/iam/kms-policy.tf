resource "aws_iam_policy" "kms" {
  name        = "${local.name_prefix}-kms-policy"
  description = "Decrypt KMS keys for secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["kms:Decrypt"]
      Effect   = "Allow"
      Resource = "*" # Ideally replace with the specific KMS Key ARN
    }]
  })
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = aws_iam_role.tableau_server.name
  policy_arn = aws_iam_policy.kms.arn
}