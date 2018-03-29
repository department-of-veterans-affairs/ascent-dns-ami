# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.9.3"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the Master DNS instance
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "master" {
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami_id}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${var.subnet_ids[length(var.subnet_ids) - 1]}"
  associate_public_ip_address = "${var.associate_public_ip_address}"

  vpc_security_group_ids      = ["${aws_security_group.dns_security_group.id}"]
  user_data                   = ["${var.user_data == "" ? template_file.master_user_data.rendered : var.user_data}"]

  tags [
    {
      key   = "Name"
      value = "${var.cluster-name}-master"
    }
    "${var.tags}",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Control Traffic to DNS instances
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "dns_security_group" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the ${var.cluster_name} instances"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  count       = "${length(var.allowed_ssh_cidr_blocks) >= 1 ? 1 : 0}"
  type        = "ingress"
  from_port   = "${var.ssh_port}"
  to_port     = "${var.ssh_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  security_group_id = "${aws_security_group.dns_security_group.id}"
}

resource "aws_security_group_rule" "allow_ssh_inbound_from_security_group_ids" {
  count                    = "${length(var.allowed_ssh_security_group_ids)}"
  type                     = "ingress"
  from_port                = "${var.ssh_port}"
  to_port                  = "${var.ssh_port}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.allowed_ssh_security_group_ids, count.index)}"

  security_group_id = "${aws_security_group.dns_security_group.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.dns_security_group.id}"
}

module "security_group_rules" {
  source = "../dns-security-group-rules"

  security_group_id                  = "${aws_security_group.dns_security_group.id}"
  allowed_inbound_cidr_blocks        = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_inbound_security_group_ids = ["${var.allowed_inbound_security_group_ids}"]

  dns_port        = "${var.dns_port}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Default User Data script
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "master_user_data" {
  template = "${file("${path.module}/dns-user-data.sh")}"

  vars {
    master              = true
    dns_zone            = "${var.dns_zone}"
    forward_dns_servers = "${var.forward_dns_servers}"
    query-cidrs         = "${var.query-cidrs}"
    zone-update-cidrs   = "${var.zone-update-cidrs}"
  }
}

data "template_file" "slave_user_data" {
  template = "${file("${path.module}/dns-user-data.sh")}"

  vars {
    dns_zone            = "${var.dns_zone}"
    forward_dns_servers = "${var.forward_dns_servers}"
    query-cidrs         = "${var.query-cidrs}"
    zone-update-cidrs   = "${var.zone-update-cidrs}"
  }
}