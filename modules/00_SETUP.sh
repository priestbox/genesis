#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		00_SETUP.sh -- priest:	Hope that firewall works because your screwed
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------	

#		HOST=$HOST # xargs placeholder

		echo "[*]	Setup directory structure"

		if [ -z "${HOST}" ]; then
			echo "Usage: recon.host <target.com>"
			exit 1

		elif [ ! -d '$HOME/WORKZONE/data-active/"$HOST"' ]; then
	
			mkdir -p "$HOME/WORKZONE/data-active/$HOST"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-active"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/js"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/urls"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/nuclei"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/cloud"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/dirsearch"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap/nmap-xml"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap/nmap-html"
			mkdir -p "$HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap/nmap-split"
			cd "$HOME/WORKZONE/data-active/$HOST" 
			clear
			ls -la
		else
			echo "[*]	$HOME/WORKZONE/data-active/$HOST Exists: Exiting!"
			exit 1
		fi
