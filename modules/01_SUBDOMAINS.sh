#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_SUBDOMAINS.sh -- Bulk collection of target HOSTNAMES list
#-------------------------------------------------------------------------------------------------------------------------------------------

#		01_SUBDOMAINS.sh 

		export HOST=$HOST # xargs placeholder
		: > 01.HOSTS.lst	# NULL file.log
	
		echo "[*]	Gathering bulk list of domains with all enumerators"

		curl -s "https://crt.sh/?q=.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | grep -w $HOST\$ | sort | anew 01.HOSTS.lst
		#	gau --subs $HOST | unfurl -u domains | sort | anew 01.HOSTS.lst		#	API KEYS REQUIRED	$HOME/.gau.toml
		#	waybackurls $HOST | unfurl -u domains | sort | anew 01.HOSTS.lst	#	For completeness
		subfinder -d $HOST -t 35 -all -silent | sort | anew 01.HOSTS.lst		#	API KEYS REQUIRED	$HOME/.config/subfinder/provider-config.yaml
		#	assetfinder --subs-only $HOST | sort | anew 01.HOSTS.lst
	
		wc -l 01.HOSTS.lst
#		echo -e "\n"