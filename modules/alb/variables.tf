variable "project_name" { type = string }
variable "environment"  { type = string }
variable "vpc_id"       { type = string }
variable "subnets"      { type = list(string) }
variable "security_groups" { type = list(string) }

variable "target_instance_id" {
  description = "The EC2 instance ID for the target group"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}