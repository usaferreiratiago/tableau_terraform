variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource tagging)"
  type        = string
  default     = "tableau-server"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, qa)"
  type        = string
}

variable "license_key" {
  description = "Tableau license key"
  type        = string
  sensitive   = true
}

variable "tableau_admin_username" {
  description = "Tableau administrator username"
  type        = string
}

variable "tableau_admin_password" {
  description = "Tableau administrator password"
  type        = string
  sensitive   = true
}

variable "tableau_admin_pass" {
  description = "Tableau administrator password alias"
  type        = string
  sensitive   = true
}

variable "ssh_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
  sensitive   = true
}

module "tableau" {

  source = "./modules/tableau"

  instance_private_ip    = module.ec2.private_ip
  license_key            = var.license_key
  tableau_admin_username = var.tableau_admin_username
  tableau_admin_password = var.tableau_admin_password
  tableau_admin_pass     = var.tableau_admin_pass
  ssh_key_path           = var.ssh_key_path
  ssh_private_key_path   = var.ssh_private_key_path

}