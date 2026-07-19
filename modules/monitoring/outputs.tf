output "health_check_id" {
  description = "The ID of the Route53 health check"
  value       = aws_route53_health_check.tableau_health.id
}

output "dashboard_name" {
  description = "The name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.tableau_dashboard.dashboard_name
}