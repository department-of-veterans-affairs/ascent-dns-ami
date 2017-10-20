#!/bin/bash -ex

set -x
if [ -e /var/named/dynamic/internal.vets-api.zone-master ] || [ -e /var/named/dynamic/internal.vets-api.zone-slave ]
then
  echo server was already configured
else

  #setup variables to connect to aws
  INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
  AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

  #determin if this is the master or slave server depending on server tags
  TYPE=`aws --output text --region $AWS_REGION ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=tag:Type,Values=*" | awk '{print $5}'`

  echo $TYPE

  if [ $TYPE == 'dns_master' ]
  then
     echo 'copy master conf'
     sudo cp /root/named.conf-master /etc/named.conf
     sudo cp /root/internal.vets-api.zone-master /var/named/dynamic/internal.vets-api.zone-master
  else
     echo 'copy slave conf'
     sudo cp /root/named.conf-slave /etc/named.conf
     MASTER_INSTANCE_ID=`aws --output text --region $AWS_REGION ec2 describe-tags --filters 'Name=tag:Type,Values=dns_master' | awk '{print $3}'`
     SERVER_IP=`aws ec2 describe-instances --instance-id $MASTER_INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PrivateIpAddress |sed 's/\"//g'`
     sed -i -e 's/IP/'$SERVER_IP'/g' /etc/named.conf
     sudo cp /root/internal.vets-api.zone-slave /var/named/dynamic/internal.vets-api.zone-slave

  fi

  #update dhcp address and restart network
  #sudo sed -i '$a supersede domain-name-servers 127.0.0.1;' /etc/dhcp/dhclient.conf
  echo "supersede domain-name-servers 127.0.0.1;" >> /etc/dhcp/dhclient.conf
  sudo /etc/init.d/network restart
fi

