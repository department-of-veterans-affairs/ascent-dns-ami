# DNS Security Group Rules Module

This folder contains a [Terraform](https://www.terraform.io/) module that defines the security group rules used by a 
DNS server to control the traffic that is allowed to go in and out of the instances. 

Normally, you'd get these rules by default if you're using the [dns-cluster module](https://github.com/department-of-veterans-affairs/ascent-dns-ami), but if 
you're running DNS on top of a different cluster, then you can use this module to add the necessary security group 
rules to that cluster. 

```hcl
module "security_group_rules" {
  source = "git::git@github.com:department-of-veterans-affairs/ascent-dns-ami.git//modules/dns-security-group-rules?ref=v0.0.1"

  security_group_id = "${module.test_servers.security_group_id}"
  
  # ... (other params omitted) ...
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of this module. The double slash (`//`) is intentional 
  and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `master` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.

* `security_group_id`: Use this parameter to specify the ID of the security group to which the rules in this module
  should be added.
  
You can find the other parameters in [variables.tf](variables.tf).