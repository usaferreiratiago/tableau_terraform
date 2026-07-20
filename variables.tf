############################
# General / AWS
############################

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for all created resources."
  type        = string
  default     = "tableau-server"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    Project     = "tableau-server"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

############################
# Networking
############################

variable "vpc_id" {
  description = "VPC ID to deploy into. Leave null to use the account's default VPC."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to deploy into. Leave null to use the default subnet in the first AZ of the chosen VPC."
  type        = string
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (port 22) into the instance."
  type        = list(string)
  default     = ["10.0.0.1/24"] # Restrict this to your own IP/CIDR in production
}

variable "allowed_web_cidrs" {
  description = "CIDR blocks allowed to reach Tableau Server web/admin ports (443, 80, 8850)."
  type        = list(string)
  default     = ["10.0.0.1/24"] # Restrict this to your corporate network/VPN in production
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP to the instance."
  type        = bool
  default     = true
}

variable "instance_ip" {
  description = "Optional static private IP address to assign to the EC2 instance. Must fall within the chosen subnet's CIDR range. Leave null to let AWS assign one automatically."
  type        = string
  default     = null
}

############################
# Compute
############################

variable "instance_type" {
  description = "EC2 instance type. Tableau Server minimum recommended is 4 vCPU / 16 GB RAM (e.g. m5.xlarge for production)."
  type        = string
  default     = "m5.xlarge"
}

variable "ami_id" {
  description = "AMI ID to use. Leave null to auto-select the latest Ubuntu 22.04 LTS AMI."
  type        = string
  default     = null
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to attach. Leave null to have Terraform generate a new key pair (private key saved locally)."
  type        = string
  default     = null
}

variable "root_volume_size_gb" {
  description = "Size in GB of the root EBS volume. Tableau Server needs significant local disk space."
  type        = number
  default     = 100
}

variable "root_volume_type" {
  description = "EBS volume type for the root volume."
  type        = string
  default     = "gp3"
}

variable "enable_termination_protection" {
  description = "Enable EC2 termination protection on the instance."
  type        = bool
  default     = false
}

############################
# Tableau Server install
############################

variable "tableau_installer_url" {
  description = "Direct download URL for the Tableau Server .deb installer package, e.g. https://downloads.tableau.com/esdalt/<version>/tableau-server-<version>_amd64.deb. Get the current URL from https://www.tableau.com/support/releases/server"
  type        = string
}

variable "tableau_license_key" {
  description = "Tableau Server license key (or activate a trial by leaving blank and passing --trial to the installer manually)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tableau_admin_username" {
  description = "Username for the initial Tableau Server administrator account."
  type        = string
  default     = "tsadmin"
}

variable "tableau_admin_password" {
  description = "Password for the initial Tableau Server administrator account."
  type        = string
  sensitive   = true
}

variable "tableau_registration" {
  description = "Registration details required by the Tableau Server installer."
  type = object({
    first_name  = string
    last_name   = string
    email       = string
    company     = string
    title       = string
    department  = string
    industry    = string
    phone       = string
    city        = string
    state       = string
    zip         = string
    country     = string
  })
}

variable "tableau_server_fqdn" {
  description = "Optional fully qualified domain name for the Tableau Server node. Leave blank to use the instance's private DNS name."
  type        = string
  default     = ""
}
