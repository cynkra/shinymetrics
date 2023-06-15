resource "aws_instance" "zookeeper" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ZOOKEEPER_INSTANCE_TYPE
  user_data              = templatefile("templates/init_zoo_ubuntu.tftpl", { ssh_keys = [chomp("${file("ssh_keys/john_key.pub")}")] })
  vpc_security_group_ids = [module.zookeeper_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Name = "zookeeper"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
