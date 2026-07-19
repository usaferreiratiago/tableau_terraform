# 1. Backup Vault
resource "aws_backup_vault" "tableau_vault" {
  name        = "${var.project_name}-backup-vault"
  kms_key_arn = var.kms_key_arn
  tags        = local.common_tags
}

# 2. Backup Plan
resource "aws_backup_plan" "tableau_plan" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.tableau_vault.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 120

    lifecycle {
      delete_after = var.retention_days
    }
  }

  tags = local.common_tags
}

# 3. IAM Role for AWS Backup
resource "aws_iam_role" "backup_role" {
  name = "${var.project_name}-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}