module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.DNS_DOMAIN
  zone_id      = aws_route53_zone.shinymetrics.zone_id

  wait_for_validation = true
}
