variable "region" { default = "us-east-1" }
variable "project_name" { default = "tableau-prod" }
variable "environment" { default = "prod" }
variable "license_key" {
  type      = string
  sensitive = true
}
variable "db_password" {
  type      = string
  sensitive = true
}