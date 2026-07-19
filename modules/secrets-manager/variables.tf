variable "project_name" { type = string }
variable "environment"  { type = string }
variable "kms_key_id"   { description = "KMS Key ID for encryption" }

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "tableauadmin"
}