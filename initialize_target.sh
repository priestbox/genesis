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

if [ ! -d "~/WORKSPACE/rawdata/$HOST" ]; then

	mkdir -p ~/WORKSPACE/rawdata/$HOST
	mkdir -p ~/WORKSPACE/rawdata/$HOST/nmap-data
	mkdir -p ~/WORKSPACE/rawdata/$HOST/split
	cd ~/WORKSPACE/rawdata/$HOST

else
	echo "[*]	~/WORKSPACE/rawdata/$HOST Exists: Exiting!"
	exit 1
fi

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_SUBDOMAINS.sh -- Bulk collection of target HOSTNAMES list
#-------------------------------------------------------------------------------------------------------------------------------------------		

echo "[*]	Gathering bulk list of domains with 01_SUBDOMAINS.sh"
	
	: > 01.HOSTS.lst	# NULL file.log

	curl -s "https://crt.sh/?q=%25.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | sort -u | grep -w $HOST\$ | anew 01.HOSTS.lst
	gau --subs $HOST | unfurl -u domains | anew 01.HOSTS.lst				#	API KEYS REQUIRED	~/.gau.toml
	waybackurls $HOST | unfurl -u domains | anew 01.HOSTS.lst				#	For completeness
	subfinder -d $HOST -all -t 35 -silent | anew 01.HOSTS.lst				#	API KEYS REQUIRED	~/.config/subfinder/provider-config.yaml
	assetfinder --subs-only $HOST | anew 01.HOSTS.lst

	wc -l 01.HOSTS.lst

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		02_HTTPROBE.sh -- Detect live 80, 443 services
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Probing $HOST with 02_HTTPROBE.sh"

	cat 01.HOSTS.lst | httprobe -c 80 | unfurl -u domains | anew 02.HTTPROBE.ALIVE.lst

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		03_MASSDNS.sh -- Convert 02.HTTPROBE.ALIVE.lst's to IPs
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Converting 02.HTTPROBE.ALIVE.lst to 03.HTTPROBE.ALIVE.IPs.lst"

	sudo massdns -r ~/WORKSPACE/tools/massdns/lists/resolvers.txt -t A -o S -w massdns-results.txt 02.HTTPROBE.ALIVE.lst
	grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" massdns-results.txt | anew 03.MASSDNS.ALIVE.IPs.lst
	sudo rm -rf massdns-results.txt
	
echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		04_MASSCAN.sh -- TOP 2000 service ports per detected live 80, 443 IPs
#-------------------------------------------------------------------------------------------------------------------------------------------
#		Define suitable output for results/searching ie: json, xml, list etc..

echo "[*]	Probing $HOST TOP 2000 ports with 04_MASSCAN.sh"
	
	sudo masscan -iL 03.MASSDNS.ALIVE.IPs.lst --rate=1000 --banners --source-port 61000 -p `cat /usr/share/nmap/nmap-services | grep -i tcp | sort -k 3 -n -r | awk '{print $2}' | cut -d "/" -f1 | head -2000 | tr '\n' "," | sed 's/,$//'` --excludefile ~/WORKSPACE/tools/masscan/data/exclude.conf --output-format binary --output-filename 04.MASSCAN.bin
	sudo masscan --readscan 04.MASSCAN.bin -oJ 05.NMAP-SCAN-2000-ports.json

echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		05_NMAP-SCAN.sh -- Versioning, banner, vulners, http-vulners-regex, http-headers | ToDo: asn-query
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Probing IPs & Ports via 05_NMAP-SCAN.sh : Versioning, banners, vulners, http-vulners-regex, http-headers"

	cat 05.NMAP-SCAN-2000-ports.json | awk '{print $3 $9}' | tr -d , | tr '"' " " | sort -u | sed '1d' | awk '{print "nmap -p "  $2" "  $1 " -sV -oX nmap-data/"$1"-result-"$2".xml --script=banner --host-timeout 55 -vvv -Pn -R --script=vulners --script=http-vulners-regex --script=http-headers"}' | sort -u | sort -R > nmap-scan.txt

	IFS=$'\n'                                                                                                               # make newlines the only separator

	# sudo rm -rf split/*-ScanTarget                                                                                        # cleanup
	# sudo rm -rf nmap-data/*.xml                                                                                           # cleanup

	split -l 30 --additional-suffix=-ScanTarget nmap-scan.txt                                                               # split the nmap commands into smaller batches

	mv *-ScanTarget split/                                                                                                  # move split files, from PWD to split/

	for file in $(ls split/*-ScanTarget); do sleep 60 && for target in $(cat $file); do sh -c "sudo $target" & done ; done  # run each splitted file (contains 30 nmap commands) and wait for 60 seconds until the next batch

	echo -e "\n"

	sleep 60

	echo "[*]	Formatting nmap-data/ output"
	for file in $(ls nmap-data/); do xsltproc nmap-data/$file -o nmap-data/$file.html; done
	mkdir -p ~/WORKSPACE/rawdata/$HOST/nmap-data/xml	# searchsploit --nmap *.xml
	sudo mv nmap-data/*.xml nmap-data/xml/
	sudo rm nmap-scan.txt
	sleep 10
	
echo -e "\n"

#-------------------------------------------------------------------------------------------------------------------------------------------
#		06_EYEWITNESS.sh --all-protocols || --web (Default)
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 06_EYEWITNESS.sh on 02.HTTPROBE.ALIVE.lst --web" 

	python3 ~/WORKSPACE/tools/EyeWitness/Python/EyeWitness.py --prepend-https -f 02.HTTPROBE.ALIVE.lst -d $PWD/eyewitness --no-prompt --timeout 120 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
	rm geckodriver.log

echo -e "\n"


#-------------------------------------------------------------------------------------------------------------------------------------------
#		07_ANALYZE.sh -- Set user permissions .. id || id -u
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 07_ANALYZE.sh on $HOST Directory structures" 

	find ~/WORKSPACE/rawdata/$HOST -type d -print0 | xargs -0 sudo chown -R user:user

echo -e "\n"

echo "[*]	Finished Target: $HOST Initialization\n"

#EOF

