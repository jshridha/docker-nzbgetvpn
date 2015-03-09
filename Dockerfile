FROM binhex/arch-base:2015022600
MAINTAINER binhex

# additional files
##################
## NZBGET
# copy prerun bash shell script (checks for existence of nzbget config)
ADD startnzbget.sh /home/nobody/start.sh

# add supervisor conf file for app
ADD nzbget.conf /etc/supervisor/conf.d/nzbget.conf

## openVPN
# add supervisor conf file for app
ADD delugevpn.conf /etc/supervisor/conf.d/delugevpn.conf

# add bash script to create tun adapter, setup ip route and create vpn tunnel
ADD startvpn.sh /root/start.sh

# add bash script to run openvpn
ADD apps/openvpn.sh /root/openvpn.sh

# add bash script to check tunnel ip is valid
ADD apps/checkip.sh /home/nobody/checkip.sh

# add pia certificates
ADD config/ca.crt /home/nobody/ca.crt
ADD config/crl.pem /home/nobody/crl.pem

# add sample openvpn.ovpn file (based on pia netherlands)
ADD config/openvpn.ovpn /home/nobody/openvpn.ovpn

# install app
#############

# install install app using pacman, set perms, cleanup
RUN pacman -Sy --noconfirm && \
	pacman -S nzbget --noconfirm && \
	pacman -S net-tools openvpn unrar unzip p7zip --noconfirm && \
	chmod +x /root/start.sh /root/openvpn.sh /home/nobody/checkip.sh && \
	chown -R nobody:users /usr/bin/nzbget /usr/share/nzbget/nzbget.conf /home/nobody/start.sh && \
	chmod -R 775 /usr/bin/nzbget /usr/share/nzbget/nzbget.conf /home/nobody/start.sh && \
	yes|pacman -Scc && \	
	rm -rf /usr/share/locale/* && \
	rm -rf /usr/share/man/* && \
#	rm -rf /root/* && \
	rm -rf /tmp/*
	
# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store downloads or use blackhole)
VOLUME /data

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# expose port for http
EXPOSE 6789

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]