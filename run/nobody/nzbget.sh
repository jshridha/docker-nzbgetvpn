#!/bin/bash

#CONFIG_DIR=/usr/share/nzbget
CONFIG_DIR=/usr/sbin/nzbget_bin

# if config file doesnt exist then copy stock config file
if [[ ! -f /config/nzbget.conf ]]; then

	echo "[info] Nzbget config file doesn't exist, copying default..."
	cp $CONFIG_DIR/nzbget.conf /config/

	# set maindir to /data folder for downloads
	sed -i 's/MainDir=~\/downloads/MainDir=\/data/g' /config/nzbget.conf
	sed -i '/MainDir=${AppDir}\/downloads/ s/=.*/=\/data/' /config/nzbget.conf

else

	echo "[info] Nzbget config file already exists, skipping copy"
#	sed -i '/ConfigTemplate=${AppDir}/ s/=.*/=\/usr\/share\/nzbget\/nzbget.conf/' /config/nzbget.conf
	sed -i '/WebDir=${AppDir}\/webui/ s/=.*/=\/usr\/share\/nzbget\/webui/' /config/nzbget.conf

fi
sed -i '/WebDir=*/ s/=.*/=${AppDir}\/webui/' /config/nzbget.conf
sed -i '/ConfigTemplate=*/ s/=.*/=${AppDir}/webui/nzbget.conf.template/' /config/nzbget.conf
sed -i  '/ConfigTemplate=*/ s/=.*/=${AppDir}\/webui\/nzbget.conf.template/' /config/nzbget.conf

# if vpn set to "no" then don't run openvpn
if [[ "${VPN_ENABLED}" == "no" ]]; then

	echo "[info] VPN not enabled, skipping VPN tunnel local ip checks"

	# run nzbget (non daemonized, blocking)
	echo "[info] Attempting to start Nzbget..."
	/usr/bin/nzbget -D -c /config/nzbget.conf

	echo "[info] Nzbget started"

else

	echo "[info] VPN is enabled, checking VPN tunnel local ip is valid"

	# set triggers to first run
	nzbget_running="false"

	# while loop to check ip
	while true; do

		# run script to check ip is valid for tunnel device (will block until valid)
		source /home/nobody/getvpnip.sh

		# if vpn_ip is not blank then run, otherwise log warning
		if [[ ! -z "${vpn_ip}" ]]; then

			# check if nzbget is running, if not then skip reconfigure for ip
			if ! pgrep -x nzbget > /dev/null; then

				echo "[info] Nzbget not running"

				# mark as nzbget not running
				nzbget_running="false"

			else

				# if nzbget is running, then reconfigure ip
				nzbget_running="true"

			fi

			if [[ "${nzbget_running}" == "false" ]]; then

				echo "[info] Attempting to start Nzbget..."

				# run nzbget (daemonized, non-blocking)
				/usr/bin/nzbget -D -c /config/nzbget.conf

				echo "[info] Nzbget started"

			fi

			# reset triggers to negative values
			nzbget_running="false"

			if [[ "${DEBUG}" == "true" ]]; then

				echo "[debug] VPN IP is ${vpn_ip}"

			fi

		else

			echo "[warn] VPN IP not detected, VPN tunnel maybe down"

		fi

		sleep 30s

	done

fi
