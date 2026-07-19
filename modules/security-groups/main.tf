############################################
# ALB SECURITY GROUP
############################################

resource "aws_security_group" "alb" {

  name        = "${var.project_name}-${var.environment}-alb"
  description = "Application Load Balancer"

  vpc_id = var.vpc_id

  tags = {

    Name = "${var.project_name}-alb"

  }

}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 443

  to_port = 443

  cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 80

  to_port = 80

  cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_vpc_security_group_egress_rule" "alb_all" {

  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

}

############################################
# TABLEAU SERVER
############################################

resource "aws_security_group" "tableau" {

  name = "${var.project_name}-${var.environment}-tableau"

  description = "Tableau Server"

  vpc_id = var.vpc_id

  tags = {

    Name = "${var.project_name}-tableau"

  }

}

resource "aws_vpc_security_group_ingress_rule" "tableau_https" {

  security_group_id = aws_security_group.tableau.id

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 443

  to_port = 443

}

resource "aws_vpc_security_group_ingress_rule" "gateway" {

  security_group_id = aws_security_group.tableau.id

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 8850

  to_port = 8850

}

resource "aws_vpc_security_group_ingress_rule" "coordination" {

  security_group_id = aws_security_group.tableau.id

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 8060

  to_port = 8060

}

resource "aws_vpc_security_group_ingress_rule" "pgsql" {

  security_group_id = aws_security_group.tableau.id

  self = true

  ip_protocol = "tcp"

  from_port = 8061

  to_port = 8061

}

############################################
# OPTIONAL SSH
############################################

resource "aws_vpc_security_group_ingress_rule" "ssh" {

  count = var.enable_ssh ? length(var.admin_cidr_blocks) : 0

  security_group_id = aws_security_group.tableau.id

  ip_protocol = "tcp"

  from_port = 22

  to_port = 22

  cidr_ipv4 = var.admin_cidr_blocks[count.index]

}

############################################
# TABLEAU ADMIN
############################################

resource "aws_vpc_security_group_ingress_rule" "admin" {

  security_group_id = aws_security_group.tableau.id

  referenced_security_group_id = aws_security_group.alb.id

  ip_protocol = "tcp"

  from_port = 8850

  to_port = 8850

}

############################################
# INTERNAL CLUSTER
############################################

resource "aws_vpc_security_group_ingress_rule" "internal_all" {

  security_group_id = aws_security_group.tableau.id

  referenced_security_group_id = aws_security_group.tableau.id

  ip_protocol = "-1"

}

############################################
# EGRESS
############################################

resource "aws_vpc_security_group_egress_rule" "tableau_all" {

  security_group_id = aws_security_group.tableau.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

}

