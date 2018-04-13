# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the DNS cluster. This variable is used to namespace all resources created by this module."
}

variable "ami_id" {
  description = "The ID of the AMI to run in this cluster."
}

variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro)."
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the DNS cluster"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to DNS"
  type        = "list"
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the slave_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = "list"
}

# ---------------------------------------------------------------------------------------------------------------------
# DNS CONFIG PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------
variable "dns_zone" {
  description = "DNS name for the zone"
}

variable "zone_update_cidrs" {
  description = "CIDR block which can submit a DNS zone update"
}

variable "query_cidrs" {
  description = "CIDR block which can submit a DNS query"
}

variable "forward_dns_servers" {
  description = "DNS servers to forward queries to"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "user_data" {
  description = "A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-dns script, which should have been installed in the DNS AMI."
  default = ""
}

variable "master_ip" {
  description = "Private IP to assign to the master DNS server. Default to dynamic IP address"
  default = ""
}

variable "slave_ip" {
  description = "Private IPs to assign to the slave DNS servers. Default to dynamic IP address"
  default = ""
}

variable "slave_size" {
  description = "The number of slave nodes to have in the DNS cluster. We strongly recommended that you use at least 1."
  default     = 1
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  default     = ""
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = "list"
  default     = []
}

variable "allowed_ssh_security_group_ids" {
  description = "A list of security group IDs from which the EC2 Instances will allow SSH connections"
  type        = "list"
  default     = []
}

variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to DNS"
  type        = "list"
  default     = []
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
  default     = "Default"
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each EC2 Instance in the cluster."
  default     = false
}

variable "spot_price" {
  description = "The maximum hourly price to pay for EC2 Spot Instances."
  default     = ""
}

variable "tenancy" {
  description = "The tenancy of the instance. Must be one of: empty string, default or dedicated. For EC2 Spot Instances only empty string or dedicated can be used."
  default     = ""
}

variable "root_volume_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  default     = "standard"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  default     = 20
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  default     = true
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default     = "10m"
}

variable "health_check_type" {
  description = "Controls how health checking is done. Must be one of EC2 or ELB."
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Time, in seconds, after instance comes into service before checking health."
  default     = 300
}

variable "instance_profile_path" {
  description = "Path in which to create the IAM instance profile."
  default     = "/"
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  default     = 53
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  default     = 22
}

variable "tags" {
  description = "List fo extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate_at_launch' mapped to the respective values."
  type        = "list"
  default     = []
}