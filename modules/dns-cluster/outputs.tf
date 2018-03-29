output "dns_master_private_ip" {
  value = "${aws_instance.master.private_ip}"
}

output "dns_master_public_ip" {
  value = "${aws_instance.master.public_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.dns_security_group.id}"
}