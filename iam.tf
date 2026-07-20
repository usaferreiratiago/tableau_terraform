data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tableau_instance_role" {
  name               = "${var.project_name}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

# Enables AWS Systems Manager Session Manager as an alternative to SSH.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.tableau_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tableau_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.tableau_instance_role.name
}
