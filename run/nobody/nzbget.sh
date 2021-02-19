#!/bin/bash

CONFIG_DIR=/usr/sbin/nzbget_bin

if [[ ! -f /config/nzbget.conf ]]; then


	echo "[info] Nzbget config file doesn't exist, copying default..."
	cp $CONFIG_DIR/nzbget.conf /config/

	sed -i 's/MainDir=~\/downloads/MainDir=\/data/g' /config/nzbget.conf
	sed -i '/MainDir=${AppDir}\/downloads/ s/=.*/=\/data/' /config/nzbget.conf

else

	echo "[info] Nzbget config file already exists, skipping copy"
	sed -i '/WebDir=${AppDir}\/webui/ s/=.*/=\/usr\/share\/nzbget\/webui/' /config/nzbget.conf

fi
sed -i '/WebDir=*/ s/=.*/=${AppDir}\/webui/' /config/nzbget.conf
sed -i  '/ConfigTemplate=*/ s/=.*/=${AppDir}\/webui\/nzbget.conf.template/' /config/nzbget.conf


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
