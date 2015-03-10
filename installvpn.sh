#!/bin/bash

# define pacman packages
pacman_packages="net-tools openvpn"

# install pre-reqs
pacman -Sy --noconfirm
pacman -S --needed $pacman_packages --noconfirm

# set permissions
chown -R nobody:users /home/nobody
chmod -R 775 /home/nobody

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
