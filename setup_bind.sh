#!/bin/bash -ex

#install bind

sudo yum -y install bind bind-utils

sudo cp /tmp/named.conf-master /root/

sudo cp /tmp/named.conf-slave /root/

sudo cp /tmp/update_named_conf.sh /root/

sudo cp /tmp/named.service /usr/lib/systemd/system/named.service

sudo cp /tmp/internal.vets-api.zone-master /root/

sudo cp /tmp/internal.vets-api.zone-slave /root/

#sudo sed -i '$a supersede domain-name-servers 127.0.0.1;' /etc/dhcp/dhclient.conf

sudo systemctl enable named

