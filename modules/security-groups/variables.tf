variable "vpc_id" {
  description = "The VPC ID where security groups will be created"
  type        = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}