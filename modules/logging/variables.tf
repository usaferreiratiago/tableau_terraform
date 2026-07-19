variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "retention_days" {
  description = "Days until logs are transitioned to infrequent access"
  type        = number
  default     = 90
}