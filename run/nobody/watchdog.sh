#!/bin/bash

# while loop to check ip and port
while true; do

	# reset triggers to negative values
	nzbget_running="false"
	privoxy_running="false"
	ip_change="false"

	if [[ "${VPN_ENABLED}" == "yes" ]]; then

		# run script to get all required info
		source /home/nobody/preruncheck.sh

		# if vpn_ip is not blank then run, otherwise log warning
		if [[ ! -z "${vpn_ip}" ]]; then

			# check if nzbget is running, if not then skip shutdown of process
			if ! pgrep -fa "nzbget" > /dev/null; then

				echo "[info] nzbget not running"

			else

				# mark as nzbget as running
				nzbget_running="true"

			fi

			if [[ "${ENABLE_PRIVOXY}" == "yes" ]]; then

				# check if privoxy is running, if not then skip shutdown of process
				if ! pgrep -fa "/usr/bin/privoxy" > /dev/null; then

					echo "[info] Privoxy not running"

				else

					# mark as privoxy as running
					privoxy_running="true"

				fi

			fi

			if [[ "${nzbget_running}" == "false" ]]; then

				# run script to start nzbget
				source /home/nobody/nzbget.sh

			fi

			if [[ "${ENABLE_PRIVOXY}" == "yes" ]]; then

				if [[ "${privoxy_running}" == "false" ]]; then

					# run script to start privoxy
					source /home/nobody/privoxy.sh

				fi

			fi


		else

			echo "[warn] VPN IP not detected, VPN tunnel maybe down"

		fi

	else

		# check if nzbget is running, if not then start via nzbget.sh
		if ! pgrep -fa "nzbget" > /dev/null; then

			echo "[info] Nzbget not running"

			# run script to start nzbget
			source /home/nobody/nzbget.sh

		fi

		if [[ "${ENABLE_PRIVOXY}" == "yes" ]]; then

			# check if privoxy is running, if not then start via privoxy.sh
			if ! pgrep -fa "/usr/bin/privoxy" > /dev/null; then

				echo "[info] Privoxy not running"

				# run script to start privoxy
				source /home/nobody/privoxy.sh

			fi

		fi

	fi

	if [[ "${DEBUG}" == "true" && "${VPN_ENABLED}" == "yes" ]]; then
		echo "[debug] VPN IP is ${vpn_ip}"
	fi

	sleep 30s

done
