# main.tf - Complete Tableau Server Infrastructure on AWS
# This configuration follows Tableau's Enterprise Deployment Guide (EDG) reference architecture

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ============================================
# DATA SOURCES
# ============================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ============================================
# NETWORKING
# ============================================

# VPC with CIDR block
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

# Public Subnets (for Bastion and Proxy servers)
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets (for Tableau Server nodes)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "Private"
  })
}

# Data Subnets (for Repository database)
resource "aws_subnet" "data" {
  count             = length(var.data_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-data-subnet-${count.index + 1}"
    Type = "Data"
  })
}

# ============================================
# ROUTING
# ============================================

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table (No direct internet access)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt"
  })
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Data Route Table
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-data-rt"
  })
}

# Data Route Table Associations
resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.data)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

# ============================================
# SECURITY GROUPS
# ============================================

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access from allowed networks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion-sg"
  })
}

# Tableau Server Security Group
resource "aws_security_group" "tableau" {
  name        = "${var.project_name}-tableau-sg"
  description = "Security group for Tableau Server nodes"
  vpc_id      = aws_vpc.main.id

  # SSH from Bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from Bastion host"
  }

  # Tableau Server Ports
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production!
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict in production!
    description = "HTTPS access"
  }

  ingress {
    from_port   = 8000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Tableau internal services"
  }

  # PostgreSQL for repository (if using internal database)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL access within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-tableau-sg"
  })
}

# Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb-sg"
  })
}

# ============================================
# IAM ROLES & POLICIES
# ============================================

# EC2 Instance Profile for Tableau Servers
resource "aws_iam_role" "tableau_ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "tableau_ec2_ssm" {
  role       = aws_iam_role.tableau_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "tableau_ec2_s3" {
  role       = aws_iam_role.tableau_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "tableau" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.tableau_ec2_role.name
}

# Policy to prevent production destruction
resource "aws_iam_policy" "prevent_production_destroy" {
  name        = "${var.project_name}-prevent-destroy"
  description = "Prevents accidental destruction of production resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "ec2:TerminateInstances",
          "rds:DeleteDBInstance",
          "s3:DeleteBucket"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/Environment" = "production"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# ============================================
# KEY PAIR
# ============================================

resource "aws_key_pair" "tableau" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key

  tags = var.tags
}

# ============================================
# BASTION HOST
# ============================================

resource "aws_instance" "bastion" {
  count                  = var.enable_bastion ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.bastion_instance_type
  key_name               = aws_key_pair.tableau.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.tableau.name

  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data/bastion.sh", {
    project_name = var.project_name
  }))

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion"
    Role = "Bastion"
  })
}

# ============================================
# TABLEAU SERVER NODES
# ============================================

resource "aws_instance" "tableau_server" {
  count                  = var.tableau_node_count
  ami                    = var.tableau_ami_id != "" ? var.tableau_ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.tableau_instance_type
  key_name               = aws_key_pair.tableau.key_name
  subnet_id              = aws_subnet.private[count.index % length(aws_subnet.private)].id
  vpc_security_group_ids = [aws_security_group.tableau.id]
  iam_instance_profile   = aws_iam_instance_profile.tableau.name

  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
    tags = merge(var.tags, {
      Name = "${var.project_name}-server-${count.index + 1}-root"
    })
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.tableau_data_volume_size
    encrypted   = true
    tags = merge(var.tags, {
      Name = "${var.project_name}-server-${count.index + 1}-data"
    })
  }

  user_data = base64encode(templatefile("${path.module}/user_data/tableau.sh", {
    project_name      = var.project_name
    node_index        = count.index + 1
    bootstrap_script  = var.tableau_bootstrap_script
    license_key       = var.tableau_license_key
    admin_user        = var.tableau_admin_user
    admin_password    = var.tableau_admin_password
    repository_host   = var.repository_host
    repository_port   = var.repository_port
    repository_dbname = var.repository_dbname
    repository_username = var.repository_username
    repository_password = var.repository_password
  }))

  tags = merge(var.tags, {
    Name      = "${var.project_name}-server-${count.index + 1}"
    Role      = "TableauServer"
    NodeIndex = count.index + 1
  })

  depends_on = [aws_security_group.tableau]
}

# ============================================
# APPLICATION LOAD BALANCER
# ============================================

resource "aws_lb" "tableau" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "production" ? true : false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "tableau-alb-logs"
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

# Target Group for Tableau Servers
resource "aws_lb_target_group" "tableau" {
  name     = "${var.project_name}-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 30
    interval            = 60
    path                = "/vizportal/api/web/v1/status"
    port                = "traffic-port"
    protocol            = "HTTPS"
    matcher             = "200"
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-tg"
  })

  depends_on = [aws_lb.tableau]
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "tableau" {
  count            = var.tableau_node_count
  target_group_arn = aws_lb_target_group.tableau.arn
  target_id        = aws_instance.tableau_server[count.index].id
  port             = 443
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tableau.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.tableau.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tableau.arn
  }
}

# ============================================
# S3 BUCKET FOR ALB LOGS
# ============================================

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-alb-logs-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}

# ============================================
# DATA SOURCES (Caller Identity for bucket naming)
# ============================================

data "aws_caller_identity" "current" {}

# ============================================
# OUTPUTS
# ============================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.tableau.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = try(aws_instance.bastion[0].public_ip, null)
}

output "tableau_server_private_ips" {
  description = "Private IPs of the Tableau server nodes"
  value       = aws_instance.tableau_server[*].private_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}