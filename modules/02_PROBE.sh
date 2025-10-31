#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_PROBE.sh -- Detect live 80, 443 services
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------	

#		HOST=$HOST # xargs placeholder

		echo "[*]	Probing hosts.db to httpx.alive.db"

#		cat hosts.db | xargs -I % sh -c 'sudo hping3 --count 1 --verbose --destport 80,443 --ack % | grep "0% packet loss" | echo % | tee -a httprobe.alive.db'
#		cat hosts.db | httprobe -c 40 -p https:443 http:80 | anew 02.httprobe.alive.full.lst | unfurl -u domains | anew httprobe.alive.db


		httpx -l hosts.db -server -title -tech-detect -asn -status-code -favicon -location -content-length -tls-grab -cname -vhost -follow-redirects -ip -silent -threads 150 -ports 80,443,8000,8080,8443 -j -o data-active/httpx-scan.json ; jq -r '. | .url' data-active/httpx-scan.json | anew httpx.alive.full.db | unfurl -u domains | anew httpx.alive.db
		grep -E '^https?://www.' httpx.alive.full.db | sort | anew httpx.alive.full.www.db
		grep -E '^www.' httpx.alive.db | sort | anew httpx.alive.www.db

#		jq -C '.' httpx-scan.json | head -n 90
#		jq -r '. | .url' data-active/httpx-scan.json
#		jq -C '. | .url, .webserver, .tech[]' data-active/httpx-scan.json

#		jq -C '. | .url' data-active/httpx-scan.json | grep 'www.' | tr -d '"' | awk -F '//' '{print $2}' | cut -d ':' -f 1 | anew www.db
#		jq -C '. | .url' data-active/httpx-scan.json | gf interestingsubs 




