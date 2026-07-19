# 1. External Health Check
resource "aws_route53_health_check" "tableau_health" {
  fqdn              = var.tableau_fqdn
  port              = 443
  type              = "HTTPS"
  resource_path     = "/#/signin"
  failure_threshold = "3"
  request_interval  = "30"
  
  tags = merge(local.common_tags, { Name = "${var.project_name}-uptime-check" })
}

# 2. Unified Ops Dashboard
resource "aws_cloudwatch_dashboard" "tableau_dashboard" {
  dashboard_name = "${var.project_name}-health-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Route53", "HealthCheckStatus", "HealthCheckId", aws_route53_health_check.tableau_health.id]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Tableau Server Uptime Status"
        }
      }
    ]
  })
}