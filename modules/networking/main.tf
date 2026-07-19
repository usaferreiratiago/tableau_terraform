############################################
# DATA SOURCES
############################################

data "aws_availability_zones" "available" {
  state = "available"
}

############################################
# VPC
############################################

resource "aws_vpc" "this" {

  cidr_block = var.vpc_cidr

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {

    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name

  }

}

############################################
# INTERNET GATEWAY
############################################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = {

    Name = "${var.project_name}-${var.environment}-igw"

  }

}

############################################
# NAT EIP
############################################

resource "aws_eip" "nat" {

  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {

    Name = "${var.project_name}-${var.environment}-nat-eip"

  }

}

############################################
# PUBLIC SUBNETS
############################################

resource "aws_subnet" "public" {

  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {

    Name = "${var.project_name}-public-${count.index + 1}"

    Tier = "Public"

  }

}

############################################
# PRIVATE SUBNETS
############################################

resource "aws_subnet" "private" {

  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_subnets[count.index]

  availability_zone = var.availability_zones[count.index]

  tags = {

    Name = "${var.project_name}-private-${count.index + 1}"

    Tier = "Private"

  }

}

############################################
# NAT GATEWAY
############################################

resource "aws_nat_gateway" "this" {

  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id

  subnet_id = aws_subnet.public[0].id

  connectivity_type = "public"

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {

    Name = "${var.project_name}-${var.environment}-nat"

    Environment = var.environment

  }

}

############################################
# PUBLIC ROUTE TABLE
############################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-public-rt"

  }

}

############################################
# PRIVATE ROUTE TABLE
############################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  dynamic "route" {

    for_each = var.enable_nat_gateway ? [1] : []

    content {

      cidr_block = "0.0.0.0/0"

      nat_gateway_id = aws_nat_gateway.this[0].id

    }

  }

  tags = {

    Name = "${var.project_name}-${var.environment}-private-rt"

  }

}

############################################
# PUBLIC ROUTE ASSOCIATIONS
############################################

resource "aws_route_table_association" "public" {

  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id

}

############################################
# PRIVATE ROUTE ASSOCIATIONS
############################################

resource "aws_route_table_association" "private" {

  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id

}

############################################
# DEFAULT NETWORK ACL
############################################

resource "aws_default_network_acl" "default" {

  default_network_acl_id = aws_vpc.this.default_network_acl_id

  ingress {

    protocol = "-1"

    rule_no = 100

    action = "allow"

    cidr_block = var.vpc_cidr

    from_port = 0

    to_port = 0

  }

  egress {

    protocol = "-1"

    rule_no = 100

    action = "allow"

    cidr_block = "0.0.0.0/0"

    from_port = 0

    to_port = 0

  }

  tags = {

    Name = "${var.project_name}-default-acl"

  }

}

############################################
# DEFAULT SECURITY GROUP
############################################

resource "aws_default_security_group" "default" {

  vpc_id = aws_vpc.this.id

  revoke_rules_on_delete = true

  tags = {

    Name = "${var.project_name}-default-sg"

  }

}

############################################
# CLOUDWATCH LOG GROUP
############################################

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {

  name = "/aws/vpc/${var.project_name}/${var.environment}"

  retention_in_days = 30

  tags = {

    Name        = "${var.project_name}-flowlogs"
    Environment = var.environment

  }

}

############################################
# IAM ROLE FOR FLOW LOGS
############################################

data "aws_iam_policy_document" "flowlogs_assume" {

  statement {

    effect = "Allow"

    principals {

      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]

    }

    actions = [
      "sts:AssumeRole"
    ]

  }

}

resource "aws_iam_role" "flowlogs" {

  name = "${var.project_name}-${var.environment}-flowlogs-role"

  assume_role_policy = data.aws_iam_policy_document.flowlogs_assume.json

}

data "aws_iam_policy_document" "flowlogs" {

  statement {

    effect = "Allow"

    actions = [

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"

    ]

    resources = [
      "*"
    ]

  }

}

resource "aws_iam_role_policy" "flowlogs" {

  name = "${var.project_name}-flowlogs"

  role = aws_iam_role.flowlogs.id

  policy = data.aws_iam_policy_document.flowlogs.json

}

############################################
# VPC FLOW LOGS
############################################

resource "aws_flow_log" "this" {

  log_destination_type = "cloud-watch-logs"

  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name

  iam_role_arn = aws_iam_role.flowlogs.arn

  traffic_type = "ALL"

  vpc_id = aws_vpc.this.id

}

