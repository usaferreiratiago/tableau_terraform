variable "instance_ip" { type = string }
variable "ssh_key_path" { type = string }
variable "ssh_user" { type = string, default = "ec2-user" }
variable "license_key" { type = string, sensitive = true }
variable "tableau_admin_user" { type = string }
variable "tableau_admin_pass" { type = string, sensitive = true }