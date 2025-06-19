#!/bin/bash

#	CORS:
#	Log file: active.CORS.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.CORS target.com"
	else
	
		export HOST=$1

		echo -e "\033[0;32mRunning\n"; site="$HOST"; waybackurls "$site" | while read url; do target=$(curl -s -I -H "Origin: https://evil.com" -X GET $url) | if grep "https://evil.com"; then echo "[Potentional CORS VULN] $url" | anew active.CORS.log; else echo -e "$url \033[0;32mNot Vulnerable"; fi; done
		
	fi

#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------