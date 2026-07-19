variable "domain_name" {
  description = "The primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of alternative domains (e.g., ['tableau.example.com'])"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Project identifier for tagging"
  type        = string
}