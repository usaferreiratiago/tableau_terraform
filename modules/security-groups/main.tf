# 1. ALB Security Group (Public facing)
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Tableau ALB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

# 2. Tableau EC2 Security Group
module "tableau_ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name_prefix}-ec2-sg"
  description = "Security group for Tableau Server EC2"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = 8850
      to_port                  = 8850
      protocol                 = "tcp"
      description              = "Tableau TSM"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  
  egress_rules = ["all-all"]
  tags         = local.tags
}

# 3. RDS Security Group
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for Tableau RDS"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from EC2"
      source_security_group_id = module.tableau_ec2_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
  tags         = local.tags
}