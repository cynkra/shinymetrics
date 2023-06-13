resource "aws_route53_zone" "shinymetrics-private" {
  name = var.DNS_DOMAIN_PRIVATE

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone" "shinymetrics" {
  name = var.DNS_DOMAIN
}

resource "aws_route53_record" "zookeeper" {
  zone_id = aws_route53_zone.shinymetrics-private.zone_id
  name    = "zookeeper.${var.DNS_DOMAIN_PRIVATE}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.zookeeper.private_ip]
}
