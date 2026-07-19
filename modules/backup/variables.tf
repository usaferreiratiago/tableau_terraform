variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encrypting the backup vault"
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 5 * * ? *)" # Daily at 05:00 UTC
}