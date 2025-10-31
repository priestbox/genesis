#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		04_MASSCAN.sh -- TOP 2000 service ports per detected live 80, 443 IPs
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------

#		HOST=$HOST # xargs placeholder

		echo "[*]	Probing massdns.alive.ips.db TOP 2000 ports with 04_MASSCAN.sh"

		sudo masscan -iL massdns.alive.ips.db --rate=1000 --banners --source-port 61000 -p `cat /usr/share/nmap/nmap-services | grep -i tcp | sort -k 3 -n -r | awk '{print $2}' | cut -d "/" -f1 | head -2000 | tr '\n' "," | sed 's/,$//'` --excludefile $HOME/WORKZONE/tools/masscan/data/exclude.conf --output-format binary --output-filename data-active/MASSCAN.bin
		sudo masscan --readscan data-active/MASSCAN.bin -oJ data-active/NMAP-SCAN-2000-ports.json

#		echo -e "\n"