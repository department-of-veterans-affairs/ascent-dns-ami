#!/bin/bash -ex

set -x

#grab all intanceIDs with tag SAN and in running or stopped state
INSTANCES=`aws ec2 describe-instances --filters "Name=tag:SAN,Values=*" "Name=instance-state-name,Values=running,stopped"  --region us-east-1 Name=vpc-id,Values=vpc-f9740e80 | jq .Reservations[].Instances[].InstanceId |sed 's/\"//g'`

  AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

  echo $INSTANCES
  INSTANCE_LIST=$(echo $INSTANCES | tr "," "\n")
  for INSTANCE in $INSTANCE_LIST
  do
    #pull private dns name to use in update
    PRIVATEDNSNAME=`aws ec2 describe-instances --instance-id $INSTANCE --region $AWS_REGION | jq .Reservations[].Instances[].PrivateDnsName |sed 's/\"//g'`

    #pull the SAN names for an instance
    AWSSANS=`aws ec2 describe-instances  --instance-ids $INSTANCE --region $AWS_REGION | jq '.Reservations[] | .Instances[] | [(.Tags|from_entries|.SAN)]' |sed 's/\"//g' | sed 's/\]//g' | sed 's/\[//g'`

    echo $AWSSAN
    echo $PRIVATEDNSNAME

    SANLIST=$(echo $AWSSANS | tr "," "\n")
    echo $SANLIST
    for SAN in $SANLIST
    do
      echo $SAN" IN  CNAME "$PRIVATEDNSNAME"." >>  /root/internal.vets-api.zone-master
    done
  done

SERIAL=`date "+%Y%m%d%H%M%S"`
echo $SERIAL
sed -i -e 's/0123456789/'$SERIAL'/g' /root/internal.vets-api.zone-master

#freeze the zone so we can manually update the zone config
rndc freeze internal.vets-api.

#copy updated zone config to dynamic folder so bind will pick it up
cp /root/internal.vets-api.zone-master /var/named/dynamic/

#thaw the zone to allow dynamic updates again
rndc thaw internal.vets-api.
