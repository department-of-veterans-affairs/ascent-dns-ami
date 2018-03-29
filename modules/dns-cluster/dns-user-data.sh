#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# The variables below are filled in via Terraform interpolation
/opt/dns/run-dns ${master == "" ? "" : "--master"} --dns-zone "${dns_zone}" --forward-dns-servers "${forward_dns_servers}" --query-cidrs "${query-cidrs}" --zone-update-cidrs "${zone-update-cidrs}"