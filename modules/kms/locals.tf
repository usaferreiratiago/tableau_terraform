locals {
  name_prefix = "${var.project_name}-${var.environment}-kms"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}