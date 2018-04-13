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
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  private_ip                  = "${var.master_ip}"

  vpc_security_group_ids      = ["${aws_security_group.dns_security_group.id}"]
  user_data                   = "${var.user_data == "" ? data.template_file.master_user_data.rendered : var.user_data}"

  tags {
      Name = "${var.cluster_name}-master"
  }
}

resource "aws_instance" "slave" {
  count                       = "${var.slave_size}"
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami_id}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${var.subnet_ids[count.index]}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  private_ip                  = "${var.slave_ip}"

  vpc_security_group_ids      = ["${aws_security_group.dns_security_group.id}"]
  user_data                   = "${var.user_data == "" ? data.template_file.slave_user_data.rendered : var.user_data}"

  tags {
      Name = "${var.cluster_name}-slave${count.index}"
  }
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
    master_ip           = ""
    dns_zone            = "${var.dns_zone}"
    forward_dns_servers = "${var.forward_dns_servers}"
    query_cidrs         = "${var.query_cidrs}"
    zone_update_cidrs   = "${var.zone_update_cidrs}"
  }
}

data "template_file" "slave_user_data" {
  template = "${file("${path.module}/dns-user-data.sh")}"

  vars {
    master_ip           = "${aws_instance.master.private_ip}"
    dns_zone            = "${var.dns_zone}"
    forward_dns_servers = "${var.forward_dns_servers}"
    query_cidrs         = "${var.query_cidrs}"
    zone_update_cidrs   = "${var.zone_update_cidrs}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM ROLE TO EACH EC2 INSTANCE
# We can use the IAM role to grant the instance IAM permissions so we can use the AWS CLI without having to figure out
# how to get our secret AWS access keys onto the box.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.cluster_name}"
  path        = "${var.instance_profile_path}"
  role        = "${aws_iam_role.instance_role.name}"
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.instance_role.json}"
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE IAM POLICIES COME FROM THE CONSUL-IAM-POLICIES MODULE
# ---------------------------------------------------------------------------------------------------------------------

module "iam_policies" {
  source = "../dns-iam-policies"

  iam_role_id = "${aws_iam_role.instance_role.id}"
}