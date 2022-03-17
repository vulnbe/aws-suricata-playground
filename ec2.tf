resource "aws_instance" "suricata" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  source_dest_check      = false
  hibernation            = false
  iam_instance_profile   = var.instance_profile
  key_name               = var.ssh_key
  vpc_security_group_ids = [aws_security_group.suricata.id]
  user_data              = local.user_data
  tags                   = var.tags
}

locals {
  user_data = templatefile("${path.module}/templates/user-data.sh", {
  })
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
