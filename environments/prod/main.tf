variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "db_username" {
  description = "Database username for RDS instance"
  type        = string
}

# 1. Foundation: Network & Security
module "networking" {
  source = "../../modules/networking"
  project_name = var.project_name
  environment  = var.environment
}

module "security" {
  source = "../../modules/security-groups"
  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

# 2. Data & Encryption
module "kms" {
  source       = "../../modules/kms"
  project_name = var.project_name
  environment  = var.environment
}

module "secrets" {
  source     = "../../modules/secrets-manager"
  kms_key_id = module.kms.key_id
  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source = "../../modules/rds"
  vpc_security_group_ids = [module.security.rds_sg_id]
  subnet_ids             = module.networking.private_subnets
  db_username            = var.db_username
  db_password            = var.db_password
  project_name           = var.project_name
  environment            = var.environment
}

# 3. Compute & Delivery
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
}

module "ec2" {
  source = "../../modules/ec2"
  ami_id               = var.ami_id
  subnet_id            = module.networking.private_subnets[0]
  iam_instance_profile = module.iam.instance_profile_name
  vpc_security_group_ids = [module.security.tableau_ec2_sg_id]
  project_name         = var.project_name
  environment          = var.environment
}

module "alb" {
  source             = "../../modules/alb"
  vpc_id             = module.networking.vpc_id
  subnets            = module.networking.public_subnets
  security_groups    = [module.security.alb_sg_id]
  target_instance_id = module.ec2.instance_id
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-arn" # Update this
  project_name       = var.project_name
  environment        = var.environment
}

# 4. Final Configuration
module "tableau" {
  source      = "../../modules/tableau"
  instance_ip = module.ec2.private_ip
  license_key = var.license_key
  tableau_admin_user = "admin"
  tableau_admin_pass = var.db_password # Ideally use a different secret
  ssh_user           = "ec2-user"
  ssh_key_path       = "~/.ssh/id_rsa"
}