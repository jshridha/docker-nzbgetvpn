FROM binhex/arch-openvpn:2.3.9-37
MAINTAINER jshridha@gmail.com

ADD supervisor/*.conf /etc/supervisor/conf.d/
ADD setup/root/*.sh /root/
ADD setup/nobody/*.sh /home/nobody/
ADD apps/root/*.sh /root/
ADD apps/nobody/*.sh /home/nobody/

# Install the app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh

VOLUME /config /data
EXPOSE 6789

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/root/init.sh"]
