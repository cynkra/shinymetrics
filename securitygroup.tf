module "bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "ssh_access_unrestricted"
  vpc_id      = module.vpc.vpc_id
  description = "Security group to allow ssh access"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "zookeeper" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "ssh_access_ip_restricted_internal"
  vpc_id      = module.vpc.vpc_id
  description = "Security group to allow IP-restricted ssh access for cynkra team"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion.security_group_id}"
    },
    {
      rule                     = "zookeeper-2181-tcp"
      source_security_group_id = "${module.drill.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "drill" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "drill_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for drill servers"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "app" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "app_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for app servers"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion.security_group_id}"
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.alb.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "allow_mysql" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mysql_access"
  vpc_id      = module.vpc.vpc_id
  description = "Security group to allow mysql access"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = "${module.drill.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "allow_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "alb_access"
  vpc_id      = module.vpc.vpc_id
  description = "Security group to allow alb access"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_cidr_blocks = [module.vpc.vpc_cidr_block]
  egress_rules       = ["http-80-tcp", "https-443-tcp"]
}
