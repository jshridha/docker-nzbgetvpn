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
sed -i  '/ConfigTemplate=*/ s/=.*/=${AppDir}\/webui\/nzbget.conf.template/' /config/nzbget.conf

if [[ "${nzbget_running}" == "false" ]]; then

	echo "[info] Attempting to start NZBget..."

	# run NZBget (daemonized, non-blocking)
	/usr/bin/nzbget -D -c /config/nzbget.conf

	# make sure process nzbget DOES exist
	retry_count=30
	while true; do

		if ! pgrep -fa "nzbget" > /dev/null; then

			retry_count=$((retry_count-1))
			if [ "${retry_count}" -eq "0" ]; then

				echo "[warn] Wait for NZBget process to start aborted, too many retries"
				echo "[warn] Showing output from command before exit..."
				timeout 10 /usr/bin/nzbget -D -c /config/nzbget.conf ; exit 1

			else

				if [[ "${DEBUG}" == "true" ]]; then
					echo "[debug] Waiting for NZBget process to start..."
				fi

				sleep 1s

			fi

		else

			echo "[info] NZBget process started"
			break

		fi

	done

	echo "[info] Waiting for NZBget process to start listening on port 6789..."

	while [[ $(netstat -lnt | awk "\$6 == \"LISTEN\" && \$4 ~ \".6789\"") == "" ]]; do
		sleep 0.1
	done

	echo "[info] NZBget process is listening on port 6789"

fi

# set NZBget ip to current vpn ip (used when checking for changes on next run)
nzbget_ip="${vpn_ip}"
