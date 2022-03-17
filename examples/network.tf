resource "aws_subnet" "suricata" {
  vpc_id                  = data.aws_vpc.target.id
  cidr_block              = local.subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_route_table" "suricata" {
  vpc_id = data.aws_vpc.target.id
}

resource "aws_route" "suricata_default_igw" {
  route_table_id         = aws_route_table.suricata.id
  gateway_id             = data.aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "suricata" {
  subnet_id      = aws_subnet.suricata.id
  route_table_id = aws_route_table.suricata.id
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.target.id]
  }
}

data "aws_vpc" "target" {
  id = local.vpc_id == "default" ? data.aws_vpc.default.id : local.vpc_id
}

data "aws_vpc" "default" {
  default = true
}
