resource "aws_lb" "suricata" {
  name               = "suricata-load-balancer"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.subnet_id]
  tags               = var.tags
}

resource "aws_lb_target_group" "suricata" {
  name        = "suricata-target-group"
  port        = var.vxlan_port
  protocol    = "UDP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.target.id
  health_check {
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_target_group_attachment" "suricata" {
  target_group_arn = aws_lb_target_group.suricata.arn
  target_id        = aws_instance.suricata.id
}

resource "aws_lb_listener" "suricata" {
  load_balancer_arn = aws_lb.suricata.id
  port              = 4789
  protocol          = "UDP"
  default_action {
    target_group_arn = aws_lb_target_group.suricata.id
    type             = "forward"
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_vpc" "target" {
  id = data.aws_subnet.selected.vpc_id
}
