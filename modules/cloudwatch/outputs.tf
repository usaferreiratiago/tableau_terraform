output "log_group_name" {
  description = "Name of the log group for Tableau"
  value       = aws_cloudwatch_log_group.tableau_logs.name
}

output "alert_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}