variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource tagging)"
  type        = string
  default     = "tableau-server"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, qa)"
  type        = string
}