variable "ports" {
  default = {
    mysql    = "3306"
    oracle   = "1521"
    postgres = "5432"
  }
}

# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_rds" {
  name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-replica" : var.name}-sg-rds"
  description = "Security group that is needed for the RDS replica"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-replica" : var.name}-sg-rds"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_security_group_rule" "rds_sg_in" {
  count                    = "${length(var.security_groups)}"
  security_group_id        = "${aws_security_group.sg_rds.id}"
  type                     = "ingress"
  from_port                = "${lookup(var.ports, var.engine)}"
  to_port                  = "${lookup(var.ports, var.engine)}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.security_groups, count.index)}"
}

resource "aws_security_group_rule" "rds_cidr_in" {
  count             = "${length(var.allowed_cidr_blocks) == 0 ? 0 : 1}"
  security_group_id = "${aws_security_group.sg_rds.id}"
  type              = "ingress"
  from_port         = "${lookup(var.ports, var.engine)}"
  to_port           = "${lookup(var.ports, var.engine)}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed_cidr_blocks}"]
}
