locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# 1. The Role
resource "aws_iam_role" "tableau_server" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# 2. The Policy (using the file we discussed)
resource "aws_iam_policy" "production_termination_deny" {
  name        = "${local.name_prefix}-termination-deny"
  description = "Prevents accidental termination"
  policy      = file("${path.module}/policies/production_termination_deny.json")
}

# 3. Attachment
resource "aws_iam_role_policy_attachment" "deny_termination_attachment" {
  role       = aws_iam_role.tableau_server.name
  policy_arn = aws_iam_policy.production_termination_deny.arn
}

# 4. The Instance Profile (Crucial for EC2)
resource "aws_iam_instance_profile" "tableau_server" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.tableau_server.name
}