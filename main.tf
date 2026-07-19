# ---------------------------------------------------------
# Root Module: Tableau Enterprise Deployment
# ---------------------------------------------------------

variable "tableau_fqdn" {
  description = "Fully qualified domain name for the Tableau deployment"
  type        = string
}

variable "admin_email" {
  description = "Email address for Tableau monitoring alerts"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting EFS and backups"
  type        = string
}

# 1. Networking Layer
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}

# 2. Security & Compliance Layer
module "ssm" {
  source       = "./modules/ssm"
  project_name = var.project_name
}

module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
}

module "acm" {
  source       = "./modules/acm"
  project_name = var.project_name
  domain_name  = var.tableau_fqdn
}

# 3. Logging & Monitoring Layer
module "logging" {
  source       = "./modules/logging"
  project_name = var.project_name
}

module "monitoring" {
  source       = "./modules/monitoring"
  project_name = var.project_name
  tableau_fqdn = var.tableau_fqdn
  alert_email  = var.admin_email
}

# 4. Storage & Persistence
module "efs" {
  source        = "./modules/efs"
  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  subnet_ids    = module.networking.private_subnets
  kms_key_arn   = var.kms_key_arn
  tableau_sg_id = module.networking.tableau_sg_id
}

module "backup" {
  source       = "./modules/backup"
  project_name = var.project_name
  kms_key_arn  = var.kms_key_arn
}

# 5. Routing Layer
module "route53" {
  source       = "./modules/route53"
  zone_id      = var.dns_zone_id
  record_name  = var.tableau_subdomain
}