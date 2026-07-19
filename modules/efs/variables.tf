variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where EFS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS Key ARN for EFS encryption"
  type        = string
}

variable "tableau_sg_id" {
  description = "The Security Group ID of the Tableau EC2 instance (to allow NFS traffic)"
  type        = string
}