#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		00_SETUP.sh -- priest:	Hope that firewall works because your screwed
#
#		Tested: Debian 12 (bookworm)
#-------------------------------------------------------------------------------------------------------------------------------------------	

#	00_SETUP.sh

	if [ $# -lt 1 ]; then
		echo "Usage: ./00_SETUP.sh target.com"
		exit 1
	else
		export HOST=$1
	fi

	if [ ! -d "~/WORKZONE/rawdata/$HOST" ]; then

		mkdir -p ~/WORKZONE/rawdata/$HOST
		mkdir -p ~/WORKZONE/rawdata/$HOST/nmap-data
		mkdir -p ~/WORKZONE/rawdata/$HOST/split
		cd ~/WORKZONE/rawdata/$HOST

	else
		echo "[*]	~/WORKZONE/rawdata/$HOST Exists: Exiting!"
		exit 1
	fi