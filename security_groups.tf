resource "aws_security_group" "tableau" {
  name        = "${var.project_name}-sg"
  description = "Security group for Tableau Server host"
  vpc_id      = data.aws_vpc.selected.id

  # SSH administration
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Tableau Server primary web/gateway traffic
  ingress {
    description = "HTTPS - Tableau web client"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidrs
  }

  ingress {
    description = "HTTP - Tableau web client (redirects to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidrs
  }

  # TSM (Tableau Services Manager) administration controller
  ingress {
    description = "TSM administration web UI"
    from_port   = 8850
    to_port     = 8850
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidrs
  }

  # Internal range used by Tableau Server's various services
  # (VizQL, Data Server, Backgrounder, Repository, etc.) on a single node.
  # Only opened to the same trusted CIDRs, not the public internet.
  ingress {
    description = "Tableau internal service ports"
    from_port   = 8000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.1/24"]
  }

  tags = merge(var.tags, {

    Name        = "${var.project_name}-instance"
    Environment = var.environment

  })
}
