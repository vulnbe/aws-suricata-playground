resource "aws_ec2_traffic_mirror_filter" "all_non_local" {
  description = "Mirror all non-local traffic"
}

resource "aws_ec2_traffic_mirror_target" "suricata_nlb" {
  description               = "Suricata NLB target"
  network_load_balancer_arn = aws_lb.suricata.arn
  tags                      = var.tags
}

resource "aws_ec2_traffic_mirror_filter_rule" "rulein" {
  count                    = var.mirror_all_traffic ? 0 : 1
  description              = "Reject local traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.all_non_local.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = data.aws_vpc.target.cidr_block
  rule_number              = 10
  rule_action              = "reject"
  traffic_direction        = "ingress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "rulein2" {
  description              = "Accept all ingress"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.all_non_local.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 20
  rule_action              = "accept"
  traffic_direction        = "ingress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "rule_out" {
  count                    = var.mirror_all_traffic ? 0 : 1
  description              = "Reject local egress traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.all_non_local.id
  destination_cidr_block   = data.aws_vpc.target.cidr_block
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 10
  rule_action              = "reject"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "rule_out2" {
  description              = "Accept all egress traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.all_non_local.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 20
  rule_action              = "accept"
  traffic_direction        = "egress"
}
