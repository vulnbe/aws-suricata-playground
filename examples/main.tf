locals {
  aws_region    = "eu-central-1"
  aws_profile   = "security-tf"
  subnet_cidr   = "172.31.129.0/24"
  vpc_id        = "default"
  instance_type = "t3.medium"
  tags          = { team = "security" }
  skip_tags     = { mirror = "false" }
  suricata_tags = merge(local.tags, local.skip_tags, { application = "suricata" })
}

module "suricata" {
  source           = "../"
  aws_region       = local.aws_region
  aws_profile      = local.aws_profile
  subnet_id        = aws_subnet.suricata.id
  instance_profile = aws_iam_instance_profile.ssm_managed_instance.name
  tags             = local.tags
  suricata_tags    = local.suricata_tags
  skip_tags        = local.skip_tags
}

resource "aws_instance" "suricata_test" {
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = local.instance_type
  subnet_id            = aws_subnet.suricata.id
  hibernation          = false
  iam_instance_profile = aws_iam_instance_profile.ssm_managed_instance.name
  credit_specification {
    cpu_credits = "standard"
  }
  depends_on = [
    module.suricata
  ]
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
