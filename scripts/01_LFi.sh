#!/bin/bash

#	LFi:
#	Log file: active.LFi.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.LFi target.com"
	else
	
		export HOST=$1

#		OPTION:	ffuf -w $HOME/WORKLISTS/Payloads/LFI.1 -u $url -H "Host: FUZZ" -mc 200 | anew active.LFi.log; done

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf lfi | qsreplace "FUZZ" | while read url ; do ffuf -u $url -t 100 -c -w $HOME/WORKZONE/payloads/LFI.1 -ac -sa -t 20 -od active.LFi.log ; done
		
	fi
	
#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------