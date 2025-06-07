#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		04_MASSCAN.sh -- TOP 2000 service ports per detected live 80, 443 IPs
#-------------------------------------------------------------------------------------------------------------------------------------------
#		Define suitable output for results/searching ie: json, xml, list etc..

echo "[*]	Probing $HOST TOP 2000 ports with 04_MASSCAN.sh"

	export TOOLS=$HOME/WORKZONE/tools

	sudo masscan -iL 03.MASSDNS.ALIVE.IPs.lst --rate=1000 --banners --source-port 61000 -p `cat /usr/share/nmap/nmap-services | grep -i tcp | sort -k 3 -n -r | awk '{print $2}' | cut -d "/" -f1 | head -2000 | tr '\n' "," | sed 's/,$//'` --excludefile $TOOLS/masscan/data/exclude.conf --output-format binary --output-filename 04.MASSCAN.bin
	sudo masscan --readscan 04.MASSCAN.bin -oJ 05.NMAP-SCAN-2000-ports.json

echo -e "\n"