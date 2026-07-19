module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.4.0"

  name               = local.name
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets
  security_groups    = var.security_groups

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.certificate_arn
      
      forward = {
        target_group_key = "tableau"
      }
    }
  }

  target_groups = {
    tableau = {
      name_prefix      = "tbl-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = var.target_instance_id
      health_check = {
        enabled             = true
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
      }
    }
  }

  tags = local.tags
}