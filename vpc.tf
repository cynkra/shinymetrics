module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0.1"

  name = var.PROJ
  cidr = "10.1.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
  }
}
