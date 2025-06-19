#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		00_SETUP.sh -- priest:	Hope that firewall works because your screwed
#
#		Tested: Debian 12 (bookworm)
#-------------------------------------------------------------------------------------------------------------------------------------------	

#		00_SETUP.sh

		export HOST=$HOST # xargs placeholder

		if [ ! -d "$HOME/WORKZONE/rawdata/$HOST" ]; then
	
			mkdir -p $HOME/WORKZONE/rawdata/$HOST
			mkdir -p $HOME/WORKZONE/rawdata/$HOST/nmap-data
			mkdir -p $HOME/WORKZONE/rawdata/$HOST/split
			cd $HOME/WORKZONE/rawdata/$HOST

		else
			echo "[*]	$HOME/WORKZONE/rawdata/$HOST Exists: Exiting!"
			exit 1
		fi