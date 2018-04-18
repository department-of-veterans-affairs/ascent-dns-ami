#!/bin/bash -ex

set -x

cp /root/internal.vets-api.zone-master /root/internal.vets-api.zone-master-update

AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

#grab all intanceIDs with tag SAN and in running or stopped state
INSTANCES=`/usr/local/aws/bin/aws ec2 describe-instances --filters "Name=tag:SAN,Values=*" "Name=instance-state-name,Values=running,stopped"  --region $AWS_REGION "Name=vpc-id,Values=vpc-ae6ac2cb,vpc-7e69c11b" | jq .Reservations[].Instances[].InstanceId |sed 's/\"//g'`

  echo $INSTANCES
  INSTANCE_LIST=$(echo $INSTANCES | tr "," "\n")
  for INSTANCE in $INSTANCE_LIST
  do
    #pull private dns name to use in update
    PRIVATEDNSNAME=`/usr/local/aws/bin/aws ec2 describe-instances --instance-id $INSTANCE --region $AWS_REGION | jq .Reservations[].Instances[].PrivateDnsName |sed 's/\"//g'`

    #pull the SAN names for an instance
    AWSSANS=`/usr/local/aws/bin/aws ec2 describe-instances  --instance-ids $INSTANCE --region $AWS_REGION | jq '.Reservations[] | .Instances[] | [(.Tags|from_entries|.SAN)]' |sed 's/\"//g' | sed 's/\]//g' | sed 's/\[//g'`

    echo $AWSSAN
    echo $PRIVATEDNSNAME

    SANLIST=$(echo $AWSSANS | tr "," "\n")
    echo $SANLIST
    for SAN in $SANLIST
    do
      SAN=$(echo $SAN |  awk -F. '{print $1}')
      echo $SAN" IN  CNAME "$PRIVATEDNSNAME"." >>  /root/internal.vets-api.zone-master-update
    done
  done

#grab all ELBs with SAN tag
ELBS=`/usr/local/aws/bin/aws elb describe-load-balancers --region $AWS_REGION | jq  '.LoadBalancerDescriptions[]  | .LoadBalancerName' |sed 's/\"//g'`

echo $ELBS
ELB_LIST=$(echo $ELBS | tr "," "\n")
for ELB in $ELB_LIST
 do
   echo $ELB
   #see if ELB has SAN tag
   AWSSANS=`/usr/local/aws/bin/aws elb describe-tags --load-balancer-names $ELB --region $AWS_REGION | jq -r '.TagDescriptions[] | [(.Tags|from_entries|.SAN)]' |sed 's/\"//g' | sed 's/\]//g' | sed 's/\[//g'`
   echo "AWSSANS " $AWSSANS
   if [ $AWSSANS = null ]
   then
     echo "No SAN Tag found. script will exit and not add this server to DNS"
   else
     SANLIST=$(echo $AWSSANS | tr "," "\n")

     echo $SANLIST

     for SAN in $SANLIST
     do
       SAN=$(echo $SAN |  awk -F. '{print $1}')
       PRIVATEDNSNAME=`/usr/local/aws/bin/aws elb describe-load-balancers --load-balancer-name $ELB --region $AWS_REGION | jq -r '.LoadBalancerDescriptions[] | .DNSName'`
       echo $SAN" IN  CNAME "$PRIVATEDNSNAME"." >>  /root/internal.vets-api.zone-master-update
     done
   fi

 done
SERIAL=`date "+%Y%m%d%H"`
echo $SERIAL
sed -i -e 's/0123456789/'$SERIAL'/g' /root/internal.vets-api.zone-master-update

#freeze the zone so we can manually update the zone config
/usr/sbin/rndc freeze internal.vets-api.gov.

#reload zone to push updates out of jnl file
/usr/sbin/rndc reload internal.vets-api.gov.

#thaw the zone to allow dynamic updates again
/usr/sbin/rndc thaw internal.vets-api.gov.

#freeze the zone so we can manually update the zone config
/usr/sbin/rndc freeze internal.vets-api.gov.

#copy updated zone config to dynamic folder so bind will pick it up
cp /root/internal.vets-api.zone-master-update /var/named/dynamic/internal.vets-api.zone-master

#thaw the zone to allow dynamic updates again
/usr/sbin/rndc thaw internal.vets-api.gov.

rm -rf /root/internal.vets-api.zone-master-update
