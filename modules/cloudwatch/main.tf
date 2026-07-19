# 1. SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# 2. Log Groups
resource "aws_cloudwatch_log_group" "tableau_logs" {
  name              = "/tableau/server/logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn # Apply KMS encryption
}

resource "aws_sns_topic" "alerts" {
  name              = "${var.project_name}-alerts"
  kms_master_key_id = var.kms_key_arn # Apply KMS encryption
}

# 3. CPU Alarm (Example of proactive monitoring)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "High CPU usage on Tableau Server"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  # Note: This requires the instance ID variable if you want to link it
  # dimensions = { InstanceId = var.instance_id }
}