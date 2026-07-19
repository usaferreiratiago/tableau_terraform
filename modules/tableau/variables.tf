variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "license_key" {
  type      = string
  sensitive = true
}

variable "tableau_admin_pass" {
  type      = string
  sensitive = true
}

variable "instance_private_ip" {
  description = "Private IP address of the Tableau EC2 instance"

  type = string

  nullable = false
}