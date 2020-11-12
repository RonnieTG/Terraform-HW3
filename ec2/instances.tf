resource "aws_instance" "web_server" {
  ami = module.VPC.aws_ami_id
  count = 2
  instance_type          = var.instance_type
  subnet_id              = module.VPC.public_subnet[count.index]
  vpc_security_group_ids = [module.VPC.aws_security_group_web_servers]
  key_name               = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.web_server.name
  user_data = file("./installnginx.sh")
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "10"
    volume_type = "standard"
    encrypted = true
  }

  tags = { Name = "Web-${count.index + 1}" }
}

resource "aws_instance" "db_server" {
  ami = module.VPC.aws_ami_id
  count = 2
  instance_type          = var.instance_type
  subnet_id              = module.VPC.private_subnet[count.index]
  vpc_security_group_ids = [module.VPC.aws_security_group_db_servers]
  key_name               = var.key_name
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "10"
    volume_type = "standard"
    encrypted = true
  }

  tags = { Name = "DB-${count.index + 1}" }
}