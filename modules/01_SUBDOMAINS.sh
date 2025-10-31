#/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		01_SUBDOMAINS.sh -- priest:	Hope that firewall works because your screwed
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------	

#		HOST=$HOST # xargs placeholder

		echo "[*]	Gathering bulk list of domains with all enumerators to hosts.db"

		: > hosts.db	# NULL file.log

		curl -s "https://crt.sh/?q=.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | grep -w $HOST\$ | sort | anew hosts.db

		#	gau --subs $HOST | unfurl -u domains | sort | anew hosts.db	#	API KEYS REQUIRED	$HOME/.gau.toml
		#	waybackurls $HOST | unfurl -u domains | sort | anew hosts.db	#	<comment>
		#	assetfinder --subs-only $HOST | sort | anew hosts.db		#	<comment>

		subfinder -d $HOST -t 35 -all -silent | sort | anew hosts.db		#	API KEYS REQUIRED	$HOME/.config/subfinder/provider-config.yaml

		cat hosts.db | grep -E "admin|administrator|root|sysadmin|secure|api|gateway|auth|login|sso|dev|developer|test|stage|staging|uat|beta|demo|internal|intranet|vpn|portal|dashboard|manage|management|config|control|server|db|database|backup|files|static|cdn" | anew hosts.admin.db

		cp hosts.db hosts.full.db
		wc -l hosts.db
#		echo -e "\n"