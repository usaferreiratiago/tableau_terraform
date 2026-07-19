resource "aws_instance" "tableau" {
  ami                  = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = local.security_groups
  user_data            = data.template_file.user_data.rendered

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = local.tags
}