variable "project_name" { type = string }
variable "environment"  { type = string }

variable "key_usage" {
  description = "The intended use of the key"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}