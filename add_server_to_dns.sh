#!/bin/bash -ex

set -x
if [ -e /root/nsupdate.txt ]
then
  echo "server already in DNS nothing to do"
else
  #grab intanceID and aws region 
  INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
  AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

  echo $INSTANCE_ID

  #pull private dns name to use in update
  PRIVATEDNSNAME=`aws ec2 describe-instances --instance-id $INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PrivateDnsName |sed 's/\"//g'`

  #pull the SAN names for an instance
  AWSSANS=`aws ec2 describe-instances  --instance-ids $INSTANCE_ID --region $AWS_REGION | jq '.Reservations[] | .Instances[] | [(.Tags|from_entries|.SAN)]' |sed 's/\"//g' | sed 's/\]//g' | sed 's/\[//g'`

  echo $AWSSAN
  echo $PRIVATEDNSNAME

  SANLIST=$(echo $AWSSANS | tr "," "\n")
  echo $SANLIST
  
  if [ $SANLIST = null ]
  then
    echo "No SAN Tag found. script will exit and not add this server to DNS"
    exit 
  else
    echo "zone internal.vets-api." >/root/nsupdate.txt
    echo "server 172.31.21.91" >>/root/nsupdate.txt
    for SAN in $SANLIST
    do
       echo "update add" $SAN".internal.vets-api. 0 CNAME "$PRIVATEDNSNAME >>/root/nsupdate.txt
    done

    echo "send" >>/root/nsupdate.txt

    nsupdate /root/nsupdate.txt
  fi
  #update dhcp address and restart network
  sudo sed -i '$a supersede domain-name-servers ;' /etc/dhcp/dhclient.conf
  sudo /etc/init.d/network restart
fi
