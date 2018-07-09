###############################################################################
# REQUIRED VARIABLES
###############################################################################

variable "security_group_id" {
  description = "The ID of the security group to which we should add the DNS security group rules"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to DNS"
  type        = "list"
}

variable "allowed_monitor_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections from monitor server"
  type        = "list"
}


###############################################################################
# OPTIONAL VARIABLES
###############################################################################

variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to DNS"
  type        = "list"
  default     = []
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  default     = 53
}

variable "monitor_port" {
  description = "TCP port for monitoring."
  default     = 9100
}

