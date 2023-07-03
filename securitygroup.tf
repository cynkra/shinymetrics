module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "bastion_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Bastion security group"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "cron_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "cron_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Cron security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion_sg.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "zookeeper_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "zookeeper_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Zookeeper security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion_sg.security_group_id}"
    },
    {
      rule                     = "zookeeper-2181-tcp"
      source_security_group_id = "${module.drill_sg.security_group_id}"
    },
    {
      rule                     = "zookeeper-2181-tcp"
      source_security_group_id = "${module.app_sg.security_group_id}"
    }

  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "drill_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "drill_sg"
  vpc_id      = module.vpc.vpc_id
  description = "Drill security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion_sg.security_group_id}"
    },
    {
      from_port                = 31010
      to_port                  = 31012
      protocol                 = "tcp"
      source_security_group_id = "${module.zookeeper_sg.security_group_id}"
    },
   {
      from_port                = 31010
      to_port                  = 31012
      protocol                 = "tcp"
      source_security_group_id = "${module.app_sg.security_group_id}"
    }
 
  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "app_sg"
  vpc_id      = module.vpc.vpc_id
  description = "App security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.bastion_sg.security_group_id}"
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.alb_sg.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mysql_sg"
  vpc_id      = module.vpc.vpc_id
  description = "MySQL security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = "${module.app_sg.security_group_id}"
    },
    {
      rule                     = "mysql-tcp"
      source_security_group_id = "${module.cron_sg.security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
}

module "alb_sg" {
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
