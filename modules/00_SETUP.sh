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

	if [ ! -d "~/WORKSPACE/rawdata/$HOST" ]; then

		mkdir -p ~/WORKSPACE/rawdata/$HOST
		mkdir -p ~/WORKSPACE/rawdata/$HOST/nmap-data
		mkdir -p ~/WORKSPACE/rawdata/$HOST/split
		cd ~/WORKSPACE/rawdata/$HOST

	else
		echo "[*]	~/WORKSPACE/rawdata/$HOST Exists: Exiting!"
		exit 1
	fi