variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "log_retention_days" {
  description = "Days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "alarm_email" {
  description = "Email address for critical alerts"
  type        = string
}