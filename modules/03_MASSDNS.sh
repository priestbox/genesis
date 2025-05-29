#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		03_MASSDNS.sh -- Convert 02.HTTPROBE.ALIVE.lst's to IPs
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Converting 02.HTTPROBE.ALIVE.lst to 02.HTTPROBE.ALIVE.IPs.lst"

	export TOOLS=$HOME/WORKSPACE/tools

	sudo massdns -r $TOOLS/massdns/lists/resolvers.txt -t A -o S -w massdns-results.txt 02.HTTPROBE.ALIVE.lst
	grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" massdns-results.txt | anew 03.MASSDNS.ALIVE.IPs.lst
	sudo rm -rf massdns-results.txt
	
echo -e "\n"