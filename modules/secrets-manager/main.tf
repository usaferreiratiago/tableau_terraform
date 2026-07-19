# Generate a random password for RDS
resource "random_password" "db_password" {
  length  = 24
  special = false
}

# 1. DB Credentials Secret
module "db_secret" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.2"

  name = "${local.name_prefix}-db-secret"
  kms_key_id = var.kms_key_id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })

  tags = local.tags
}

# 2. Placeholder for Tableau Admin Credentials (can be updated later)
module "tableau_admin_secret" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.2"

  name = "${local.name_prefix}-tableau-admin"
  kms_key_id = var.kms_key_id

  secret_string = jsonencode({
    admin_user = "admin"
    admin_pass = "ChangeMe123!" 
  })

  tags = local.tags
}