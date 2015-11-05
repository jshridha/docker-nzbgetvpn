FROM phusion/baseimage:0.9.17
MAINTAINER Bungy

##VPN

# additional files
##################

# add supervisor conf file for app
ADD *.conf /etc/supervisor/conf.d/

# add bash scripts to install app, and setup iptables, routing etc
ADD *.sh /root/

# add bash script to run openvpn
ADD apps/root/*.sh /root/

# add bash script to check tunnel ip is valid
ADD apps/nobody/*.sh /home/nobody/

# add pia certificates and sample openvpn.ovpn file
ADD config/pia/* /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/installvpn.sh && /bin/bash /root/installnzbget.sh

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store data from app)
VOLUME /data

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# expose port for nzbget webgui
EXPOSE 6789

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]

