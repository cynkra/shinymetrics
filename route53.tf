resource "aws_route53_zone" "drill-private" {
  name = var.PROJ

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "zookeeper" {
  zone_id = aws_route53_zone.drill-private.zone_id
  name    = "zookeeper.${var.PROJ}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.zookeeper.private_ip]
}
