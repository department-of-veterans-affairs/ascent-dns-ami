  # ascent-dns-ami

These scripts build a DNS image using Hashicorp packer. Base RHEL7, the bind, aws cli, and the jq shell JSON parser are installed.

 ## To run
 
Create user variable JSON file:
```
   {
    "aws_access_key": "xxxxxxxxxxxxxxxxxxxxxxxxx",
    "aws_secret_key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "aws_region": "us-east-1",
    "base_ami_id": "ami-c998b6b2",
   }
```

and run packer build -var-file=<your_user_file>.json base.json

  ## On the EC2 instances
- One AWS tags is used to control if the server is the master of the slave
  - "Type" - if set to "dns_master" the ec2 instance will set configs so that this server is designated as the master.  if set to     "dns_slave" the ec2 instance will set configs so that this server is designated as the slave. 
  
