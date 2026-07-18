# main.tf - Complete Tableau Server Infrastructure on AWS

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

data "aws_caller_identity" "current" {}

# ============================================
# NETWORKING
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

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

# Route Tables
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

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-data-rt"
  })
}

resource "aws_route_table_association" "data" {
  count          = length(aws_subnet.data)
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

# ============================================
# SECURITY GROUPS
# ============================================

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

resource "aws_security_group" "tableau" {
  name        = "${var.project_name}-tableau-sg"
  description = "Security group for Tableau Server nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from Bastion host"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  ingress {
    from_port   = 8000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Tableau internal services"
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
# IAM ROLES
# ============================================

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
  count = var.tableau_node_count > 0 ? 1 : 0
  
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "production" ? true : false

  tags = merge(var.tags, {
    Name = "${var.project_name}-alb"
  })
}

resource "aws_lb_target_group" "tableau" {
  count = var.tableau_node_count > 0 ? 1 : 0
  
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
}

resource "aws_lb_target_group_attachment" "tableau" {
  count            = var.tableau_node_count > 0 ? var.tableau_node_count : 0
  target_group_arn = aws_lb_target_group.tableau[0].arn
  target_id        = aws_instance.tableau_server[count.index].id
  port             = 443
}

resource "aws_lb_listener" "http" {
  count = var.tableau_node_count > 0 ? 1 : 0
  
  load_balancer_arn = aws_lb.tableau[0].arn
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

resource "aws_lb_listener" "https" {
  count = var.tableau_node_count > 0 && var.certificate_arn != "" ? 1 : 0
  
  load_balancer_arn = aws_lb.tableau[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tableau[0].arn
  }
}