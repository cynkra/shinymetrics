resource "aws_route53_zone" "shinymetrics-private" {
  name = var.DNS_DOMAIN_PRIVATE

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone" "shinymetrics" {
  name = var.DNS_DOMAIN
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "zookeeper" {
  zone_id = aws_route53_zone.shinymetrics-private.zone_id
  name    = "zookeeper.${var.DNS_DOMAIN_PRIVATE}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.zookeeper.private_ip]
}

resource "aws_route53_record" "shinymetrics" {
  zone_id = aws_route53_zone.shinymetrics.zone_id
  name    = var.DNS_DOMAIN
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
