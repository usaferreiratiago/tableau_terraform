# Use an explicit resource ARN instead of "*"
resource "aws_iam_policy" "kms" {
  name = "${var.project_name}-kms-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["kms:Decrypt", "kms:DescribeKey"]
      Effect   = "Allow"
      Resource = [var.kms_key_arn] # Pass this in as a variable
    }]
  })
}

resource "aws_iam_role_policy_attachment" "kms" {
  role       = aws_iam_role.tableau_server.name
  policy_arn = aws_iam_policy.kms.arn
}