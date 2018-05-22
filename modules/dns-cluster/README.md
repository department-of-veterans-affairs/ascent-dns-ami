# DNS Cluster Module
This folder contains a [Terraform](https://www.terraform.io/) module that can be used to deploy a DNS cluster in [AWS](https://aws.amazon.com/). This module is designed to deploy an [Amazon Machine Image (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) that has DNS cluster installed via the [packer scripts](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer) in this project.

## How do you use this module?
This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```
module "dns" {
  # Use version 1.0.3 of the dns-cluster module
  source = "github.com/department-of-veterans-affairs/ascent-dns-ami.git//modules/dns-cluster?ref=v1.0.3"

  # Provide an Amazon Machine Image ID to deploy the instance with
  ami_id        = "ami-abc123"

  # Specify whether we want to make these dns servers public or private
  associate_public_ip_address = false

  # Tie down the master server to a specific IP
  master_ip = "10.247.81.246"

  # DNS zone for all of the domains
  dns_zone = "my.cool.project.com"

  # .... See variables.tf for all other required parameters as well as the optional ones
}
```
Note the following parameters:
- `source`: Use this parameter to specify the URL of the dns-cluster module. The double slash (//) is intentional and required. Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific Git tag in this repo. That way, instead of using the latest version of this module from the master branch, which will change every time you run Terraform, you're using a fixed version of the repo.
- `ami_id`: The ID of the Amazon Machine Image that the dns-cluster should run on.
- `associate_public_ip_address`: Use this parameter to make your dns servers external or internal. A value of `false` will not make the dns servers reachable unless you're on the subnet via a bastion or VPN. A value of `true` makes the DNS servers reachable via the public internet.
- `master_ip`: This makes the master DNS server a specific IP address so you can know in advance what the IP of the server is.
- `dns_zone`: Set the zone for your domain names.

You can find the other parameters in [variables.tf](https://github.com/department-of-veterans-affairs/ascent-dns-ami/blob/master/modules/dns-cluster/variables.tf)


## What's included in this module?
This architecture consists of the following resources:
- [Elastic Compute Cloud (EC2) Instance](#ec2-instance)
- [Security Group](#security-group)
- [IAM Roles and Permissions](#iam-roles-and-permissions)

### EC2 Instance
The following EC2 Instances are deployed with this configuration:
- DNS Master Instance: A master DNS instance that controls the cluster and pushes any required updates to the rest of the cluster.
- DNS Slave Instance(s): Any amount of instances used to forward requests to if the master or other slaves are down.

### Security Group
The DNS servers have a security group that allows:
- Inbound UDP & TCP traffic through a DNS port (default 53) for specified CIDR blocks.
- Inbound UDP & TCP traffic for specific security group IDs.
- Inbound SSH traffic through an SSH port (default 22)

## How do you roll out updates?
The Master DNS server is configured to run a nightly cron that queries all EC2 Instances with a SAN tag. It takes the value of the SAN tag, creates a new record if it doesn't exist, and pushes that out to all of the Slave Instances.


## What's NOT included in this module?
This module does NOT handle the following items, which you may want to provide on your own:
- [Monitoring, alerting, log aggregation](#monitoring-alerting-log-aggregation)
- [VPCs, subnets, route tables](#vpcs-subnets-route-tables)

### Monitoring, alerting, log aggregation
This module does not include anything for monitoring, alerting, or log aggregation. All EC2 Instances come with limited CloudWatch metrics built-in, but beyond that, you will have to provide your own solutions. We have an on going solution for implementing Prometheus, but that is still a work in progress


### VPCs, subnets, route tables
This module assumes you've already created your network topology (VPC, subnets, route tables, etc). You will need to pass in the the relevant info about your network topology (e.g. `vpc_id`, `subnet_ids`) as input variables to this module.
