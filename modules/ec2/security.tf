# This acts as a logical container for security group associations
locals {
  security_groups = var.vpc_security_group_ids
}