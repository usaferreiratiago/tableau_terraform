locals {
  name = "${var.project_name}-${var.environment}-alb"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}