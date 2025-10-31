#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------------------------
#	initialize_target.sh	--	priest:	Hope that firewall works because your screwed
#
#	Tested: Debian 12 (bookworm)
#-------------------------------------------------------------------------------------------------------------------------------------------

if [ $# -lt 1 ]; then
	echo 'Usage: ./initialize_target.sh target.com'
	exit 1
else
	export HOST=$1
fi

if [ ! -d "$HOME/WORKZONE/data-active/$HOST" ]; then

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

else
		echo "[*]	$HOME/WORKZONE/data-active/$HOST Exists: Exiting!"
	exit 1
fi

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_SUBDOMAINS.sh -- Bulk collection of target HOSTNAMES list
#-------------------------------------------------------------------------------------------------------------------------------------------		

echo "[*]	Gathering bulk list of domains with 01_SUBDOMAINS.sh"
	
		: > hosts.db	# NULL file.log

		curl -s "https://crt.sh/?q=.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | grep -w $HOST\$ | sort | anew hosts.db

		#	gau --subs $HOST | unfurl -u domains | sort | anew hosts.db	#	API KEYS REQUIRED	$HOME/.gau.toml
		#	waybackurls $HOST | unfurl -u domains | sort | anew hosts.db	#	<comment>
		#	assetfinder --subs-only $HOST | sort | anew hosts.db		#	<comment>

		subfinder -d $HOST -t 35 -all -silent | sort | anew hosts.db		#	API KEYS REQUIRED	$HOME/.config/subfinder/provider-config.yaml

		cp hosts.db hosts.full.db
		wc -l hosts.db

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		02_PROBE.sh -- Detect live 80, 443 services
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Probing $HOST with 02_PROBE.sh"

		httpx -l hosts.db -server -title -tech-detect -asn -status-code -favicon -location -content-length -tls-grab -cname -vhost -follow-redirects -ip -silent -threads 150 -ports 80,443,8000,8080,8443 -j -o data-active/httpx-scan.json ; jq -r '. | .url' data-active/httpx-scan.json | anew httpx.alive.full.db | unfurl -u domains | anew httpx.alive.db

		grep -E '^https?://www.' httpx.alive.full.db | sort | anew httpx.alive.full.www.db
		grep -E '^www.' httpx.alive.db | sort | anew httpx.alive.www.db

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		03_MASSDNS.sh -- Convert httpx.alive.db to IPs
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Converting httpx.alive.db to massdns.alive.ips.db"

		sudo massdns -r $HOME/WORKZONE/tools/massdns/lists/resolvers.txt -t A -o S -w data-active/massdns-results.txt httpx.alive.db
		grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" data-active/massdns-results.txt | anew massdns.alive.ips.db
	
echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		04_MASSCAN.sh -- TOP 2000 service ports per detected live 80, 443 IPs
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Probing $HOST TOP 2000 ports with 04_MASSCAN.sh"
	
		sudo masscan -iL massdns.alive.ips.db --rate=1000 --banners --source-port 61000 -p `cat /usr/share/nmap/nmap-services | grep -i tcp | sort -k 3 -n -r | awk '{print $2}' | cut -d "/" -f1 | head -2000 | tr '\n' "," | sed 's/,$//'` --excludefile $HOME/WORKZONE/tools/masscan/data/exclude.conf --output-format binary --output-filename data-active/MASSCAN.bin
		sudo masscan --readscan data-active/MASSCAN.bin -oJ data-active/NMAP-SCAN-2000-ports.json

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		05_NMAP-SCAN.sh -- Versioning, banner, vulners, http-vulners-regex, http-headers | ToDo: asn-query
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Probing IPs & Ports via 05_NMAP-SCAN.sh : Versioning, banners, vulners, http-vulners-regex, http-headers"

		echo "[*]	Probing IPs & Ports via 05_NMAP-SCAN.sh: Versioning, banners, vulners, http-vulners-regex, http-headers"

		cat data-active/NMAP-SCAN-2000-ports.json | awk '{print $3 $9}' | tr -d , | tr '"' " " | sort -u | sed '1d' | awk '{print "nmap -p "  $2" "  $1 " -sV -oX data-enumeration/nmap/nmap-html/"$1"-result-"$2".xml --script=banner --host-timeout 55 -vvv -Pn -R --script=vulners --script=http-vulners-regex --script=http-headers"}' | sort -u | sort -R > data-active/nmap-scan.txt

		IFS=$'\n'									# make newlines the only separator

		# sudo rm -rf split/*-ScanTarget						# cleanup
		# sudo rm -rf nmap-html/*.xml							# cleanup

		split -l 30 --additional-suffix=-ScanTarget data-active/nmap-scan.txt		# split the nmap commands into smaller batches

		mv *-ScanTarget data-enumeration/nmap/nmap-split/				# move split files, from PWD to split/

		for file in $(ls data-enumeration/nmap/nmap-split/*-ScanTarget); do sleep 60 && for target in $(cat $file); do sh -c "sudo $target" & done ; done  # run each splitted file (contains 30 nmap commands) and wait for 60 seconds until the next batch

		echo -e "\n"

		sleep 60

		echo "[*]	Formatting data-active/data-enumeration/nmap-html/ *.html && *.xml"

		#mkdir -p $HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap/nmap-xml		# searchsploit --nmap *.xml

		for file in $(ls data-enumeration/nmap/nmap-html/*.xml); do xsltproc $file -o "$file.html"; done
		sudo mv data-enumeration/nmap/nmap-html/*.xml data-enumeration/nmap/nmap-xml/

		sleep 10
	
echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		06_EYEWITNESS.sh --all-protocols || --web (Default)
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 06_EYEWITNESS.sh on httpx.alive.db" 

		source ~/.venv/bin/activate

		python3 $HOME/WORKZONE/tools/EyeWitness/Python/EyeWitness.py --prepend-https -f httpx.alive.db -d $PWD/data-enumeration/eyewitness --no-prompt --timeout 120 --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
		rm $PWD/geckodriver.log

		deactivate
echo -e "\n"


#-------------------------------------------------------------------------------------------------------------------------------------------
#		07_ANALYZE.sh -- Set user permissions .. id || id -u
#-------------------------------------------------------------------------------------------------------------------------------------------

echo -e "[*]	Running: 		07_ANALYZE.sh on $HOST Directory Structures and Cache flush\n" 

		find $HOME/WORKZONE/data-active/$HOST/. -type d -print0 | xargs -0 sudo chown -R $USER:$USER
		echo -e "[*]	Initialized Target: 	$HOST\n"
		echo -e "[*]	Execute Scanning:	08_ACTIVE.sh"

echo -e "\n"
#EOF

