module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  name = var.PROJ

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  # Attach security groups
  security_groups = [module.allow_alb.security_group_id]
  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
      #   action_type = "redirect"
      #   redirect = {
      #     port        = "443"
      #     protocol    = "HTTPS"
      #     status_code = "HTTP_301"
      #   }
    }
  ]
  #   https_listeners = [
  #     {
  #       port               = 443
  #       protocol           = "HTTPS"
  #       certificate_arn    = 
  #       target_group_index = 1
  #     }
  #   ]

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      actions = [{
        type = "forward"
        target_groups = [
          {
            target_group_index = 0
          }
        ]
      }]

      conditions = [{
        path_patterns = ["/"]
      }]
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
