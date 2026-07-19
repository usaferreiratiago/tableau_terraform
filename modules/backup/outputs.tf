output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.tableau_vault.arn
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.tableau_plan.arn
}