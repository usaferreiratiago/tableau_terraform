output "db_secret_arn" {
  description = "ARN of the DB credentials secret"
  value       = module.db_secret.secret_arn
}

output "tableau_admin_secret_arn" {
  description = "ARN of the Tableau admin secret"
  value       = module.tableau_admin_secret.secret_arn
}