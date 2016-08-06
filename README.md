**Application**

[Nzbget website](http://nzbget.net/)  
[OpenVPN website](https://openvpn.net/)  

**Description**

NZBGet is a cross-platform binary newsgrabber for nzb files, written in C++. It supports client/server mode, automatic par-check/-repair, web-interface, command-line interface, etc. NZBGet requires low system resources and runs great on routers, NAS-devices and media players.

**Build notes**

Latest stable NZBGet release from Arch Linux repo.
Latest stable OpenVPN release from Arch Linux repo.

**Usage**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 6789:6789 \
    --name=<container name> \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=<yes|no> \
    -e VPN_USER=<vpn username> \
    -e VPN_PASS=<vpn password> \
    -e VPN_REMOTE=<vpn remote gateway> \
    -e VPN_PORT=<vpn remote port> \
    -e VPN_PROTOCOL=<vpn remote protocol> \
    -e VPN_PROV=<pia|airvpn|custom> \
    -e STRONG_CERTS=<yes|no> \
    -e LAN_NETWORK=<lan ipv4 network>/<cidr notation> \
    -e DEBUG=<true|false> \
    -e PUID=<UID for user> \
    -e PGID=<GID for user> \
    jshridha/nzbgetvpn:latest
```

Please replace all user variables in the above command defined by <> with the correct values.

**Access NZBGet**

`http://<host ip>:6789`

username:- nzbget
password:- tegbzn6789

**PIA provider**

PIA users will need to supply VPN_USER and VPN_PASS, optionally define VPN_REMOTE (list of gateways https://www.privateinternetaccess.com/pages/client-support) if you wish to use another remote gateway other than the Netherlands.

**PIA example**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 8112:8112 \
    -p 8118:8118 \
    --name=nzbgetvpn \
    -v /apps/docker/nzbget/data:/data \
    -v /apps/docker/nzbget/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_USER=myusername \
    -e VPN_PASS=mypassword \
    -e VPN_REMOTE=nl.privateinternetaccess.com \
    -e VPN_PORT=1198 \
    -e VPN_PROTOCOL=udp \
    -e VPN_PROV=pia \
    -e STRONG_CERTS=no \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e DEBUG=false \
    -e PUID=0 \
    -e PGID=0 \
    jshridha/nzbgetvpn:latest
```

**AirVPN provider**

AirVPN users will need to generate a unique OpenVPN configuration file by using the following link https://airvpn.org/generator/

1. Please select Linux and then choose the country you want to connect to
2. Save the ovpn file to somewhere safe
3. Start the nzbgetvpn docker to create the folder structure
4. Stop nzbgetvpn docker and copy the saved ovpn file to the /config/openvpn/ folder on the host
5. Start nzbgetvpn docker
6. Check supervisor.log to make sure you are connected to the tunnel

**AirVPN example**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 8112:8112 \
    -p 8118:8118 \
    --name=nzbgetvpn \
    -v /apps/docker/nzbget/data:/data \
    -v /apps/docker/nzbget/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_REMOTE=nl.vpn.airdns.org \
    -e VPN_PORT=443 \
    -e VPN_PROTOCOL=udp \
    -e VPN_PROV=airvpn \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e DEBUG=false \
    -e PUID=0 \
    -e PGID=0 \
    jshridha/nzbgetvpn:latest
```

**Notes**

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

```
id <username>
```

The STRONG_CERTS environment variable is used to define whether to use strong certificates and enhanced encryption ciphers when connecting to PIA (does not affect other providers).
___
If you appreciate my work, then please consider buying me a beer  :D

[Support forum](http://lime-technology.com/forum/index.php?topic=38930)
