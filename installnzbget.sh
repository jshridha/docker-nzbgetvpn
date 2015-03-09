#!/bin/bash

# define pacman packages
pacman_packages="unzip unrar nzbget"

# install pre-reqs
pacman -Sy --noconfirm
pacman -S --needed $pacman_packages --noconfirm

# set permissions
chown -R nobody:users /usr/bin/nzbget /usr/share/nzbget/nzbget.conf /home/nobody/start.sh
chmod -R 775 /usr/bin/nzbget /usr/share/nzbget/nzbget.conf /home/nobody/start.sh

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
