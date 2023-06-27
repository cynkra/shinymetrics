module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  name = var.PROJ

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  # Attach security groups
  security_groups            = [module.alb_sg.security_group_id]
  enable_deletion_protection = true
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix      = "app-"
      backend_protocol = "HTTP"
      backend_port     = 80
    }
  ]

  tags = {
    Project = var.PROJ
  }
}
