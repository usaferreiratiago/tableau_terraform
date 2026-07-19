module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier = "${local.name_prefix}-db"

  engine               = "postgres"
  engine_version       = "15.3"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = "5432"

  multi_az               = var.environment == "prod" ? true : false
  db_subnet_group_name   = "${local.name_prefix}-db-subnet"
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_ids             = var.subnet_ids

  # Security and Backups
  storage_encrypted      = true
  deletion_protection    = var.environment == "prod" ? true : false
  skip_final_snapshot    = var.environment == "prod" ? false : true
  backup_retention_period = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}