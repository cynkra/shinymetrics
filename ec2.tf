resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.BASTION_INSTANCE_TYPE
  user_data                   = templatefile("templates/init_ec2_ubuntu.tftpl", { ssh_keys = [chomp("${file("ssh_keys/john_key.pub")}")] })
  vpc_security_group_ids      = [module.bastion.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  subnet_id                   = module.vpc.public_subnets[0]

  tags = {
    Name = "bastion"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}
