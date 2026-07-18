# variables.tf - All configurable parameters

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "tableau"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# ============================================
# NETWORKING
# ============================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "data_subnet_cidrs" {
  description = "CIDR blocks for data subnets (database)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"] # ⚠️ RESTRICT IN PRODUCTION!
}

# ============================================
# COMPUTE
# ============================================

variable "tableau_node_count" {
  description = "Number of Tableau Server nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.tableau_node_count >= 1 && var.tableau_node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "tableau_instance_type" {
  description = "EC2 instance type for Tableau Server"
  type        = string
  default     = "t3.xlarge"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "tableau_ami_id" {
  description = "Custom AMI ID for Tableau Server (leave empty to use default Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "tableau_data_volume_size" {
  description = "Size in GB for Tableau data EBS volume"
  type        = number
  default     = 500
}

variable "enable_bastion" {
  description = "Enable Bastion host for secure SSH access"
  type        = bool
  default     = true
}

# ============================================
# TABLEAU CONFIGURATION
# ============================================

variable "tableau_license_key" {
  description = "Tableau Server license key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tableau_admin_user" {
  description = "Tableau Server admin username"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "tableau_admin_password" {
  description = "Tableau Server admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tableau_bootstrap_script" {
  description = "Custom bootstrap script for Tableau installation"
  type        = string
  default     = ""
}

# ============================================
# DATABASE (REPOSITORY)
# ============================================

variable "repository_host" {
  description = "Hostname/IP of the PostgreSQL repository (external RDS or self-managed)"
  type        = string
  default     = ""
}

variable "repository_port" {
  description = "Port for PostgreSQL repository"
  type        = number
  default     = 5432
}

variable "repository_dbname" {
  description = "PostgreSQL database name for repository"
  type        = string
  default     = "tableau"
}

variable "repository_username" {
  description = "PostgreSQL username for repository"
  type        = string
  sensitive   = true
  default     = ""
}

variable "repository_password" {
  description = "PostgreSQL password for repository"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================
# LOAD BALANCER
# ============================================

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (must be in us-east-1 for ALB)"
  type        = string
  default     = ""
}

# ============================================
# SSH
# ============================================

variable "ssh_public_key" {
  description = "Your SSH public key for EC2 access"
  type        = string
  sensitive   = true
}

# ============================================
# TAGS
# ============================================

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project     = "Tableau"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}