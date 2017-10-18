#!/bin/bash



# base yum packages

sudo yum -y install wget unzip deltarpm nmap curl 



# aws cli

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

unzip awscli-bundle.zip

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws



# jq command line JSON parser

sudo wget -O /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64

sudo chmod 755 /usr/bin/jq


exit 0
