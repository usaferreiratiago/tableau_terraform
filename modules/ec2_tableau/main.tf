resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_pair_name
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip
  private_ip                  = var.instance_ip
  disable_api_termination     = var.enable_termination_protection
  user_data                   = var.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type            = var.root_volume_type
    encrypted              = true
    delete_on_termination  = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # enforce IMDSv2
    http_put_response_hop_limit = 1
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-instance"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}