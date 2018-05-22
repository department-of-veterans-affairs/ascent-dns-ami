# Ascent DNS Module
This repo contains a Module for how to deploy DNS server cluster on [Amazon Web Services (AWS)](https://aws.amazon.com/) using [Terraform](https://www.terraform.io/). [EC2 Instances](https://aws.amazon.com/ec2/) register their domain names using an [instance tag](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) with a key="SAN" and the value being whatever domain name the user of this module desires.


This Module includes:
- **dns-cluster:** This module sets up and performs the initial configuration of a dns cluster with a master/slave set up.
- **dns-iam-policies:** This module contains the policies needed for the dns servers' role so they can query the other instances for a SAN tag.
- **dns-security-group-rules:** This module contains the security group rules necessary for traffic to the dns servers.


## What's a Module?
Modules in Terraform are self-contained packages of Terraform configurations that are managed as a group. Modules are used to create reusable components in Terraform as well as for basic code organization. A root module is the current working directory when you run terraform apply or get, holding the Terraform configuration files. It is itself a valid module. The root module in this project is **dns-cluster**. See [https://www.terraform.io/docs/modules/usage.html] for more details for creating your own module.

## Prerequisites
- [Terraform](https://www.terraform.io/intro/getting-started/install.html)
- [Packer](https://www.packer.io/docs/install/index.html)
- An active [AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)


## How do you use this Module?
This Module has the following folder structure:
- [modules](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/modules): This folder contains the reusable code for this Module, broken down into one or more modules.
- [packer](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer): This folder contains a [packer ebs builder](https://www.packer.io/docs/builders/amazon-ebs.html) that builds the required [Amazon Machine Image (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html).

#### To Deploy a DNS Master Instance
1. Create an AMI that is configured as a DNS server using the [packer project](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer).
2. Deploy the AMI into a private subnet using the Terraform [dns-cluster](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer) with a Tag with a "Type" key set to a value of "dns_master"

#### To Deploy a DNS Slave Instance
1. Create an AMI that is configured as a DNS server using the [packer project](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer).
2. Deploy the AMI into a private subnet using the Terraform [dns-cluster](https://github.com/department-of-veterans-affairs/ascent-dns-ami/tree/master/packer) with a Tag with a "Type" key set to a value of "dns_slave".
