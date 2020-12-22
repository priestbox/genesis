# nahamsec & edited to taste
# =========================================================================================
#
# apt-get install jq dnsutils whois curl (bind-tools <- manjaro)
#
# Insert following into .bashrc || .bash_profile (Default), and create .bash_aliases

# if [ -f ~/.bash_aliases ]; then
#   . ~/.bash_aliases
# fi

# source .bashrc

# =========================================================================================

# Wildcard failures: certspotter.com April 2020

# No keyword %25 search ie: api, internal, dev

# curl -s https://certspotter.com/api/v0/certs\?domain\=%25api%25.$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep -w $1\$

# for i in `crtsh target.com | httprobe -c 60` ; do curl https://$i/phpinfo.php ; done
# for i in `crtsh target.com` ; do curl https://$i/phpinfo.php ; done


#	Functions	-------------------------------


crtsh()	{	  
	if [ $# -lt 1 ]; then
		echo "Usage: crtsh target.com"
		else
			# Original function
			curl -s https://crt.sh/\?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep -w $1\$	# | tee -a rawdata/$1-crtsh.txt

			# curl -s https://crt.sh/?Identity=$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF'
	fi
}

crtshroot()	{	# Adjust for root only subs			| rev | cut -d "."  -f 1,2,3$2 | sort -u | rev  
	if [ $# -lt 1 ]; then
			echo "Usage: crtshroot target.com [NULL or ',4']"
		else
			# Root sub domain test.example.com == NULL || test.example.com.ph == ,4
			curl -s https://crt.sh/\?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep -w $1\$ | rev | cut -d "."  -f 1,2,3$2 | sort -u | rev 	# | tee -a rawdata/$1-crtshroot.txt
	fi
}

crtshauto()	{
	if [ $# -lt 1 ]; then
		echo "Usage: crtshauto target.lst"
	else
		for i in `cat $1`; do 
			curl -s https://crt.sh/\?q\=%.$i\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep -w $i\$	# | tee -a rawdata/$i-crtshauto.txt
		done
	fi
}

crtshprobe()	{
	if [ $# -lt 1 ]; then
		echo "Usage: crtshprobe target.com"
	else
		curl -s https://crt.sh/\?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep -w $1\$ | httprobe -c 60	# | tee -a rawdata/$1-crtshprobe.txt
	fi
}

hosts2IP()	{
	if [ $# -lt 1 ]; then
		echo "Usage: hosts2IP target.lst"
	else
		for i in `cat $1` ; do dig +short $i | grep -Eo '[0-9\.]{7,15}' | head -1 | tee -a $1-IP.tmp ; done
		sort -u $1-IP.tmp > $1-IP.lst
		rm $1-IP.tmp
	fi
}

asn-whois()	{
	if [ $# -lt 1 ]; then
		echo "Usage: asn-whois target.com"
	else
		whois -h whois.cymru.com $(dig +short $1)
	fi
}

ipinfo()	{  # user@debian:~$ ipinfo ?	<---- IP Public
	if [ $# -lt 1 ]; then
		echo "Usage: ipinfo 192.168.0.1"
	else
		curl -s https://ipinfo.io/$1

	fi
}


#	Tooling scripts	-------------------------------


dirsearch()	{	# dirsearch and takes host and extension as arguments
	if [ $# -lt 1 ]; then
		echo "Usage: dirsearch target.com ext ie: json,html,php"
	else
		python3 ~/workspace/tools/dirsearch/dirsearch.py -u $1 -e $2 -t 50 -b 
	fi
}





