#!/bin/bash

if [[ "${nzbget_running}" == "false" ]]; then

	echo "[info] Attempting to start nzbget..."

	# run nzbget
	/usr/bin/nzbget -D -c /config/nzbget.conf

	# make sure process nzbget DOES exist
	retry_count=12
	retry_wait=1
	while true; do

		if ! pgrep -x nzbget > /dev/null; then

			retry_count=$((retry_count-1))
			if [ "${retry_count}" -eq "0" ]; then

				echo "[warn] Wait for nzbget process to start aborted, too many retries"

			else

				if [[ "${DEBUG}" == "true" ]]; then
					echo "[debug] Waiting for nzbget process to start"
					echo "[debug] Re-check in ${retry_wait} secs..."
					echo "[debug] ${retry_count} retries left"
				fi
				sleep "${retry_wait}s"

			fi

		else

			echo "[info] Nzbget process started"
			break

		fi

	done

	echo "[info] Waiting for Nzbget process to start listening on port 6789..."

	while [[ $(netstat -lnt | awk "\$6 == \"LISTEN\" && \$4 ~ \".6789\"") == "" ]]; do
		sleep 0.1
	done

	echo "[info] Nzbget process is listening on port 6789"

fi

# set nzbget ip to current vpn ip (used when checking for changes on next run)
nzbget_ip="${vpn_ip}"
