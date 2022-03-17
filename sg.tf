resource "aws_security_group" "suricata" {
  name   = "suricata-${var.aws_region}"
  vpc_id = data.aws_vpc.target.id
  tags   = var.tags

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      data.aws_vpc.target.cidr_block
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
