#!/bin/bash

# install apt packages
apt-get update -y
apt-get install -y net-tools openvpn iptables

# set permissions
chown -R nobody:users /home/nobody
chmod -R 775 /home/nobody

# cleanup
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
