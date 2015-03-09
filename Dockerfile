FROM binhex/arch-base:2015030300
MAINTAINER binhex


##NZBGET
# additional files
##################

# copy prerun bash shell script (checks for existence of nzbget config)
ADD startnzbget.sh /home/nobody/start.sh

# add supervisor conf file for app
ADD nzbgetvpn.conf /etc/supervisor/conf.d/nzbgetvpn.conf

# add install bash script
ADD installnzbget.sh /root/installnzbget.sh

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/installnzbget.sh /home/nobody/start.sh && \
	/bin/bash /root/installnzbget.sh
	
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
#CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]

##VPN

# additional files
##################

# add supervisor conf file for app
#ADD delugevpn.conf /etc/supervisor/conf.d/delugevpn.conf

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

# add install bash script
ADD installvpn.sh /root/installvpn.sh

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/installvpn.sh /root/start.sh /root/openvpn.sh /home/nobody/checkip.sh && \
	/bin/bash /root/installvpn.sh

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store data from app)
VOLUME /data

# expose port for nzbget webui
EXPOSE 6789

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]