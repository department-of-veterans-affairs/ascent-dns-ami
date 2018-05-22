# DNS IAM Policies Module
This folder contains a [Terraform](https://www.terraform.io/) module contains the policy and policy configurations needed to
discover other instances' dns names

## What this module contains
This module provides an 'Allow' policy to the following actions:
- [ec2:DescribeInstances](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html)
- [ec2:DescribeTags](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeTags.html)
- [autoscaling:DescribeAutoScalingGroups](https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DescribeAutoScalingGroups.html)
- [elasticloadbalancing:DescribeLoadBalancers](https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_DescribeLoadBalancers.html)
- [elasticloadbalancing:DescribeTags](https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_DescribeTags.html)

## How do you use this module?
This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```
module "iam_policies" {
  # Use version 1.0.3 of this module
  source = "github.com/department-of-veterans-affairs/ascent-dns-ami.git//modules/dns-iam-policies?ref=v1.0.3"

  # The ID of the IAM Role to attach to.
  iam_role_id = "${aws_iam_role.instance_role.id}"
}
```

Note the following parameters:
- `source`: Use this parameter to specify the URL of the dns-iam-policies module. The double slash (//) is intentional and required. Terraform uses it to specify subfolders within a Git repo (see module sources). The ref parameter specifies a specific Git tag in this repo. That way, instead of using the latest version of this module from the master branch, which will change every time you run Terraform, you're using a fixed version of the repo.
- `iam_role_id`: Use this parameter to define the [Identity and Access Management (IAM) Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) to attach the policy to.
