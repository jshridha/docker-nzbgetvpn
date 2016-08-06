#!/bin/bash

# check if nzbget.conf exists, if not copy sample config
if [[ -f /config/nzbget.conf ]]; then

	echo "nzbget.conf exists"
  sed -i '/ConfigTemplate=${AppDir}/ s/=.*/=\/usr\/share\/nzbget\/nzbget.conf/' /config/nzbget.conf
	sed -i '/WebDir=${AppDir}\/webui/ s/=.*/=\/usr\/share\/nzbget\/webui/' /config/nzbget.conf

else

	# copy to /config
	cp /usr/share/nzbget/nzbget.conf /config/

	# set maindir to /data folder for downloads
  sed -i 's/MainDir=~\/downloads/MainDir=\/data/g' /config/nzbget.conf
  sed -i '/MainDir=${AppDir}\/downloads/ s/=.*/=\/data/' /config/nzbget.conf

fi

# if vpn set to "no" then don't run openvpn
if [[ $VPN_ENABLED == "no" ]]; then

	echo "[info] VPN not enabled, skipping VPN tunnel local ip checks"

	nzbget_ip="0.0.0.0"

	# run nzbget
	echo "[info] All checks complete, starting nzbget..."

	# run nzbget daemon (non daemonized, blocking)
	echo "[info] All checks complete, starting nzbget..."
	# start nzbget non-daemonised and specify config file
	/usr/bin/nzbget -D -c /config/nzbget.conf

else

	echo "[info] VPN is enabled, checking VPN tunnel local ip is valid"

	# create pia client id (randomly generated)
	client_id=`head -n 100 /dev/urandom | md5sum | tr -d " -"`

	# run script to check ip is valid for tun0
	source /home/nobody/checkip.sh

	# set triggers to first run
	first_run="true"
	reload="false"

	# set default values for port and ip
	nzbget_port="6890"
	nzbget_ip="0.0.0.0"

	# set sleep period for recheck (in mins)
	sleep_period="10"

	# while loop to check ip and port
	while true; do

		# run scripts to identity vpn ip
		source /home/nobody/getvpnip.sh

		# if vpn_ip is not blank then run, otherwise log warning
		if [[ ! -z "${vpn_ip}" ]]; then

			# check nzbget is running, if not then set to first_run and reload
			if ! pgrep -f /usr/bin/nzbget > /dev/null; then

				echo "[info] nzbget daemon not running, marking as first run"

				# mark as first run and reload required due to nzbget not running
				first_run="true"
				reload="true"

			else

				# if current bind interface ip is different to tunnel local ip then re-configure nzbget
				if [[ $nzbget_ip != "$vpn_ip" ]]; then

					echo "[info] nzbget listening interface IP $nzbget_ip and VPN provider IP different, marking for reload"

					# mark as reload required due to mismatch
					first_run="false"
					reload="true"

				fi

			fi

			if [[ $VPN_PROV == "pia" ]]; then

				# run scripts to identify vpn port
				source /home/nobody/getvpnport.sh

				if [[ $first_run == "false" ]]; then

					# if vpn port is not an integer then log warning
					if [[ ! $vpn_port =~ ^-?[0-9]+$ ]]; then

						echo "[warn] PIA incoming port is not an integer, downloads will be slow, does PIA remote gateway supports port forwarding?"

						# set vpn port to current nzbget port, as we currently cannot detect incoming port (line saturated, or issues with pia)
						vpn_port="${nzbget_port}"

					elif [[ $nzbget_port != "$vpn_port" ]]; then

						echo "[info] nzbget incoming port $nzbget_port and VPN incoming port $vpn_port different, marking for reload"

						# mark as reload required due to mismatch
						first_run="false"
						reload="true"

					# run netcat to identify if port still open, use exit code
					nc_exitcode=$(/usr/bin/nc -z -w 3 "${nzbget_ip}" "${nzbget_port}")

					elif [[ "${nc_exitcode}" -ne 0 ]]; then

						echo "[info] nzbget incoming port closed, marking for reload"

						# mark as reload required due to mismatch
						first_run="false"
						reload="true"

					fi

				else

					# if vpn port is not an integer then log warning
					if [[ ! $vpn_port =~ ^-?[0-9]+$ ]]; then

						echo "[warn] PIA incoming port is not an integer, downloads will be slow, does PIA remote gateway supports port forwarding?"

						# set vpn port to current nzbget port, as we currently cannot detect incoming port (line saturated, or issues with pia)
						vpn_port="${nzbget_port}"

					fi

					# mark as reload required due to first run
					first_run="true"
					reload="true"

				fi

			fi

			if [[ $reload == "true" ]]; then

				if [[ $first_run == "false" ]]; then

					echo "[info] Reload required, configuring nzbget..."

					# set nzbget ip to current vpn ip (used when checking for changes on next run)
					nzbget_ip="${vpn_ip}"

					if [[ $VPN_PROV == "pia" ]]; then

						# set nzbget port to current vpn port (used when checking for changes on next run)
						nzbget_port="${vpn_port}"


					fi

				else


					# set nzbget ip to current vpn ip (used when checking for changes on next run)
					nzbget_ip="${vpn_ip}"

					echo "[info] All checks complete, starting nzbget..."

					# start nzbget non-daemonised and specify config file
					/usr/bin/nzbget -D -c /config/nzbget.conf

					if [[ $VPN_PROV == "pia" ]]; then

						# wait for nzbget daemon process to start (listen for port)
						while [[ $(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".58846"') == "" ]]; do
							sleep 0.1
						done


						# set nzbget port to current vpn port (used when checking for changes on next run)
						nzbget_port="${vpn_port}"

					fi

				fi

			fi

			# reset triggers to negative values
			first_run="false"
			reload="false"

		else

			echo "[warn] VPN IP not detected"

		fi

		if [[ "${DEBUG}" == "true" ]]; then

			echo "[debug] VPN incoming port is $vpn_port"
			echo "[debug] nzbget incoming port is $nzbget_port"
			echo "[debug] VPN IP is $vpn_ip"
			echo "[debug] nzbget IP is $nzbget_ip"
			echo "[debug] Sleeping for ${sleep_period} mins before rechecking listen interface and port (port checking is for PIA only)"

		fi

		sleep "${sleep_period}"m

	done

fi
