output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = module.rds.db_instance_endpoint
}

output "db_arn" {
  value = module.rds.db_instance_arn
}