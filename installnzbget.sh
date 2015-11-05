#!/bin/bash

#install apt packages
apt-get install -y unzip unrar p7zip supervisor wget

# Get the installtion script
wget -O - http://nzbget.net/info/nzbget-version-linux.json | \
sed -n "s/^.*stable-download.*: \"\(.*\)\".*/\1/p" | \
wget --no-check-certificate -i - -O nzbget-latest-bin-linux.run || \
echo "*** Download failed ***"

sh nzbget-latest-bin-linux.run --destdir /nzbget

# set permissions
chown -R nobody:users /nzbget/nzbget /nzbget/nzbget.conf /home/nobody/start.sh
chmod -R 775 /nzbget/nzbget /nzbget/nzbget.conf /home/nobody/start.sh

# cleanup
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
