#!/bin/bash

# check if nzbget.conf exists, if not copy sample config
if [[ -f /config/nzbget.conf ]]; then

	echo "nzbget.conf exists"
	
	sed -i '/ConfigTemplate=\/usr\/share/ s/=.*/=${AppDir}\/webui\/nzbget.conf.template/' /config/nzbget.conf
	sed -i '/WebDir=\/usr\/share/ s/=.*/=${AppDir}\/webui/' /config/nzbget.conf

else
	
	# copy to /config
	cp /usr/share/nzbget/webui/nzbget.conf /config/

	# set maindir to /data folder for downloads
	sed -i 's/MainDir=~\/downloads/MainDir=\/data/g' /config/nzbget.conf
	
fi

#run nzbget specifying config path and daemon flag
/nzbget/nzbget -D -c /config/nzbget.conf
