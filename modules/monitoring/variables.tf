variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "tableau_fqdn" {
  description = "The fully qualified domain name of the Tableau Server"
  type        = string
}

variable "alert_email" {
  description = "Email for critical health alerts"
  type        = string
}