locals {
  name = "${var.project_name}-${var.environment}-tableau"
  tags = {
    Name        = local.name
    Project     = var.project_name
    Environment = var.environment
  }
}