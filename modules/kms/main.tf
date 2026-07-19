module "kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1.0"

  description             = "KMS key for ${local.name_prefix}"
  key_usage               = var.key_usage
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Key Policy: Allow the root account to manage the key
  create_external = false
  
  # Ensure the key is aliasable
  aliases = ["alias/${local.name_prefix}"]

  tags = local.tags
}