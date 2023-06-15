module "mysql" {

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.6.0"

  identifier = "mysql-${var.PROJ}"

  engine               = "mysql"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  engine_version       = "8.0"

  storage_type = "gp3"

  instance_class    = var.DB_INSTANCE_TYPE
  allocated_storage = 20

  username               = "mysqldb"
  create_random_password = true
  port                   = "3306"

  skip_final_snapshot                 = true
  iam_database_authentication_enabled = false
  publicly_accessible                 = false
  storage_encrypted                   = true

  tags = {
    Environment = var.PROJ
  }

  # DB subnet group (this determines the VPC the DB will be in)
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.mysql_sg.security_group_id]
}
