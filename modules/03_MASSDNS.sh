#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		03_MASSDNS.sh -- Convert 02.HTTPX.ALIVE.lst's to IPs
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------

#		HOST=$HOST # xargs placeholder

		echo "[*]	Converting httpx.alive.db to massdns.alive.ips.db"

		sudo massdns -r $HOME/WORKZONE/tools/massdns/lists/resolvers.txt -t A -o S -w data-active/massdns-results.txt httpx.alive.db
		grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" data-active/massdns-results.txt | anew massdns.alive.ips.db
#		sudo rm -rf data-active/massdns-results.txt
#		echo -e "\n"