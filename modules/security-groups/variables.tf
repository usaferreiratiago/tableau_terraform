variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for administration"

  type = list(string)

  default = [
    "0.0.0.0/0"
  ]
}

variable "enable_ssh" {
  description = "Allow SSH access"

  type    = bool
  default = false
}