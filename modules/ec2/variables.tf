variable "project_name" { type = string }
variable "environment"  { type = string }
variable "ami_id" {
  type    = string
  default = null
}
variable "instance_type" {
  type    = string
  default = "r5.2xlarge" # Tableau requires significant RAM
}
variable "subnet_id"    { type = string }
variable "iam_instance_profile" { type = string }
variable "vpc_security_group_ids" { type = list(string) }