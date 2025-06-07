#!/bin/bash

#	OPEN REDIRECT:
#	Log file: active.REDIRECT.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.REDIRECT target.com"
	else
	
		export HOST=$1

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf redirect | qsreplace "http://evil.com" | while read url ; do curl -s -L $url -I | if grep -qs "evil.com"; then echo -e "[Potential REDIRECT VULN] $url" | anew active.REDIRECT.log; else echo -e "$url \033[0;32mNot Vulnerable"; fi; done
		
	fi

#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------