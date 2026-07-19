# 1. EFS Security Group (Restricted access)
resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow NFS traffic from Tableau EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.tableau_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# 2. EFS File System (Encrypted)
resource "aws_efs_file_system" "tableau_efs" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true
  kms_key_id     = var.kms_key_arn

  tags = local.common_tags
}

# 3. Mount Targets
resource "aws_efs_mount_target" "mount" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.tableau_efs.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}