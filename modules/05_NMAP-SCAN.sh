#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		05_NMAP-SCAN.sh -- Versioning, banner, vulners, http-vulners-regex, http-headers | ToDo: asn-query
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------

#		HOST=$HOST # xargs placeholder

		echo "[*]	Probing IPs & Ports via 05_NMAP-SCAN.sh: Versioning, banners, vulners, http-vulners-regex, http-headers"

		cat data-active/NMAP-SCAN-2000-ports.json | awk '{print $3 $9}' | tr -d , | tr '"' " " | sort -u | sed '1d' | awk '{print "nmap -p "  $2" "  $1 " -sV -oX data-enumeration/nmap/nmap-html/"$1"-result-"$2".xml --script=banner --host-timeout 55 -vvv -Pn -R --script=vulners --script=http-vulners-regex --script=http-headers"}' | sort -u | sort -R > data-active/nmap-scan.txt

		IFS=$'\n'									# make newlines the only separator

		# sudo rm -rf split/*-ScanTarget						# cleanup
		# sudo rm -rf nmap-html/*.xml							# cleanup

		split -l 30 --additional-suffix=-ScanTarget data-active/nmap-scan.txt		# split the nmap commands into smaller batches

		mv *-ScanTarget data-enumeration/nmap/nmap-split/				# move split files, from PWD to split/

		for file in $(ls data-enumeration/nmap/nmap-split/*-ScanTarget); do sleep 60 && for target in $(cat $file); do sh -c "sudo $target" & done ; done  # run each splitted file (contains 30 nmap commands) and wait for 60 seconds until the next batch

		echo -e "\n"

		sleep 60

		echo "[*]	Formatting data-active/data-enumeration/nmap-html/ *.html && *.xml"

		#mkdir -p $HOME/WORKZONE/data-active/$HOST/data-enumeration/nmap/nmap-xml		# searchsploit --nmap *.xml

		for file in $(ls data-enumeration/nmap/nmap-html/*.xml); do xsltproc $file -o "$file.html"; done
		sudo mv data-enumeration/nmap/nmap-html/*.xml data-enumeration/nmap/nmap-xml/

		sleep 10
	
#		echo -e "\n"
