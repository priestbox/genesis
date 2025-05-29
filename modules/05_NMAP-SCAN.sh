#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		05_NMAP-SCAN.sh -- Versioning, banner, vulners, http-vulners-regex, http-headers | ToDo: asn-query
#-------------------------------------------------------------------------------------------------------------------------------------------
#		.json output parsing depends on masscan source: git, apt-get. Check: sed '1d;$d'

	if [ $# -lt 1 ]; then
		echo "Usage: ./05_NMAP-SCAN.sh target.com"		# target.com to set $HOST Directory *.xml data
	else
		export HOST=$1

		echo "[*]	Probing IPs & Ports via 05_NMAP-SCAN.sh: Versioning, banners, vulners, http-vulners-regex, http-headers"

		cat 05.NMAP-SCAN-2000-ports.json | awk '{print $3 $9}' | tr -d , | tr '"' " " | sort -u | sed '1d' | awk '{print "nmap -p "  $2" "  $1 " -sV -oX nmap-data/"$1"-result-"$2".xml --script=banner --host-timeout 55 -vvv -Pn -R --script=vulners --script=http-vulners-regex --script=http-headers"}' | sort -u | sort -R > nmap-scan.txt

		IFS=$'\n'                                                                                                               # make newlines the only separator

		# sudo rm -rf split/*-ScanTarget                                                                                        # cleanup
		# sudo rm -rf nmap-data/*.xml                                                                                           # cleanup

		split -l 30 --additional-suffix=-ScanTarget nmap-scan.txt                                                               # split the nmap commands into smaller batches

		mv *-ScanTarget split/                                                                                                  # move split files, from PWD to split/

		for file in $(ls split/*-ScanTarget); do sleep 60 && for target in $(cat $file); do sh -c "sudo $target" & done ; done  # run each splitted file (contains 30 nmap commands) and wait for 60 seconds until the next batch

		echo -e "\n"

		sleep 60

		echo "[*]	Formatting nmap-data/ output"
		for file in $(ls nmap-data/); do xsltproc nmap-data/$file -o nmap-data/$file.html; done
		mkdir -p ~/WORKSPACE/rawdata/$HOST/nmap-data/xml	# searchsploit --nmap *.xml					EDIT: $HOST Directory
		sudo mv nmap-data/*.xml nmap-data/xml/
		sudo rm nmap-scan.txt
		sleep 10
	
		echo -e "\n"

	fi
