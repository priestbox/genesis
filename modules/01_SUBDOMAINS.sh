#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_SUBDOMAINS.sh -- Bulk collection of target HOSTNAMES list
#-------------------------------------------------------------------------------------------------------------------------------------------
#		

#	01_SUBDOMAINS.sh 

	if [ $# -lt 1 ]; then
		echo "Usage: ./01_SUBDOMAINS.sh target.com"
	else
		export HOST=$1
		: > 01.HOSTS.lst	# NULL file.log
	
	echo "[*]	Gathering bulk list of domains with 01_SUBDOMAINS.sh"

		curl -s "https://crt.sh/?q=%25.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | sort -u | grep -w $HOST\$ | anew 01.HOSTS.lst
		gau --subs $HOST | unfurl -u domains | anew 01.HOSTS.lst		#	API KEYS REQUIRED	~/.gau.toml
		waybackurls $HOST | unfurl -u domains | anew 01.HOSTS.lst		#	For completeness
		subfinder -d $HOST -all -t 35 -silent | anew 01.HOSTS.lst		#	API KEYS REQUIRED	~/.config/subfinder/provider-config.yaml
		assetfinder --subs-only $HOST | anew 01.HOSTS.lst
	
		wc -l 01.HOSTS.lst

	echo -e "\n"

	fi