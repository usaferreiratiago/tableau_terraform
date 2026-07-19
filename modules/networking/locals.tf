locals {
  name = "${var.project_name}-${var.environment}"
  tags = {
    Name        = local.name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}