module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.environment == "dev" ? true : false
  
  # Add this line below
  enable_flow_log = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}