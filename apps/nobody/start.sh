#!/bin/bash

# check if nzbget.conf exists, if not copy sample config
if [[ -f /config/nzbget.conf ]]; then

	echo "nzbget.conf exists"
	
else
	
	# copy to /config
	cp /usr/share/nzbget/nzbget.conf /config/

	# set maindir to /data folder for downloads
	sed -i 's/MainDir=~\/downloads/MainDir=\/data/g' /config/nzbget.conf
	
fi

#run nzbget specifying config path and daemon flag
/usr/bin/nzbget -D -c /config/nzbget.conf