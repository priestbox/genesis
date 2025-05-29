#	neural.priest
#
#---------------------------------------------------------------------------------------------------------------------------------------
#	.bash_aliases	--	priest:	Hope that firewall works because your screwed
#
#	Tested: Debian 12 (bookworm)
#---------------------------------------------------------------------------------------------------------------------------------------
#
# 	apt-get install jq dnsutils whois curl
#
# 	Insert following into .bashrc || .bash_profile || create .bash_aliases
#
# 	if [ -f ~/.bash_aliases ]; then
# 	  . ~/.bash_aliases
# 	fi
#
# 	source .bashrc
#
#---------------------------------------------------------------------------------------------------------------------------------------
#	PATH settings	--------------------------------------------------------------------------------------------------------------------

export TOOLS=$HOME/WORKSPACE/tools
export SCRIPTS=$HOME/WORKSPACE/scripts

#---------------------------------------------------------------------------------------------------------------------------------------
#	Basic sub-routines	----------------------------------------------------------------------------------------------------------------

ipinfo()	{  # user@debian:~$ ipinfo ?	<---- IP Public
	if [ $# -lt 1 ]; then
		echo "Usage: ipinfo 192.168.0.1"
	else
		curl -s https://ipinfo.io/$1

	fi
}

#---------------------------------------------------------------------------------------------------------------------------------------
#	Recon Functions	--------------------------------------------------------------------------------------------------------------------

recon.host()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: recon.host target.com"
	elif [ ! -z "$HOST" ] ; then
			export HOST=$1
			echo -e "Current : $HOST"	# NULL args display value, else current $HOST display value	
			echo -e "Usage   : recon.host target.com"
	elif [ ! "$HOST" = "$1" ] ; then
			export HOST=$1
			echo -e "Exported: $HOST"	# First args display value
	fi
}

recon.subdomains()	{

	if [ $# -lt 1 ]; then
		echo "Usage: recon.subdomains target.com"
	else
		export HOST=$1
		: > 01.HOSTS.lst	# NULL file.log
	
	echo "[*]	Gathering bulk list of domains with all reconerators"

		curl -s "https://crt.sh/?q=%25.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | sort -u | grep -w $HOST\$ | anew 01.HOSTS.lst
		gau --subs $HOST | unfurl -u domains | anew 01.HOSTS.lst				#	API KEYS REQUIRED	~/.gau.toml
		waybackurls $HOST | unfurl -u domains | anew 01.HOSTS.lst				#	For completeness
		subfinder -d $HOST -t 35 -all -silent | anew 01.HOSTS.lst				#	API KEYS REQUIRED	~/.config/subfinder/provider-config.yaml
		assetfinder --subs-only $HOST | anew 01.HOSTS.lst
	
	wc -l 01.HOSTS.lst
	echo -e "\n"
	fi
}

recon.subdomains.crtsh()	{	  
	if [ $# -lt 1 ]; then
		echo "Usage: recon.subdomains.crtsh target.com"
	else
		export HOST=$1
		# Original function
		curl -s "https://crt.sh/?q=%25.$HOST&output=json" | jq -r '.[].name_value' | sed 's/*.//g' | sort -u | grep -w $HOST\$ | anew 01.HOSTS.lst

		# Shell Escaped
		# curl -s https://crt.sh/\?q\=%25.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | grep -w $1\$
	fi
}

recon.httprobe()	{
	if [ $# -lt 1 ]; then
		echo "Usage: recon.httprobe 01.HOSTS.lst"
	else
		#FILE=$1
		cat 01.HOSTS.lst | httprobe -c 200 | unfurl -u domains | anew 02.HTTPROBE.ALIVE.lst
	fi
}

recon.massdns()	{
	if [ $# -lt 1 ]; then
		echo "Usage: recon.massdns 02.HTTPROBE.ALIVE.lst"
	else
		#FILE=$1
		sudo massdns -r $TOOLS/massdns/lists/resolvers.txt -t A -o S -w massdns-results.txt 02.HTTPROBE.ALIVE.lst
		grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" massdns-results.txt | anew 03.MASSDNS.ALIVE.IPs.lst
		sudo rm -rf massdns-results.txt
	fi
}

recon.asn()	{	# If host --help error, ASN not available
	if [ $# -lt 1 ]; then
		echo "Usage: recon.asn target.com"
	else
		HOST=$1
		whois -h "whois.cymru.com" $(dig +short $HOST);
		export HOST=""
	fi
}

#---------------------------------------------------------------------------------------------------------------------------------------
#	Active	Functions	----------------------------------------------------------------------------------------------------------------

active.LFi()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.LFi [ \$HOST / target.com ]"
	elif [ ! -z "$1" ] ; then
			HOST=$1
			echo -e "Execute 1 01_LFi.sh: $HOST"
			$SCRIPTS/01_LFi.sh $HOST
	else
			echo -e "Execute 2 01_LFi.sh: $HOST"
			$SCRIPTS/01_LFi.sh $HOST
	fi
}

active.XSS()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.XSS [ \$HOST / target.com ]"
	elif [ ! -z "$1" ] ; then
			HOST=$1
			echo -e "Execute 1 02_XSS.sh: $HOST"
			$SCRIPTS/02_XSS.sh $HOST
	else
			echo -e "Execute 2 02_XSS.sh: $HOST"
			$SCRIPTS/02_XSS.sh $HOST
	fi
}

active.SSRF()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.SSRF [ \$HOST / target.com ]"
	elif [ ! -z "$1" ] ; then
			HOST=$1
			echo -e "Execute 1 03_SSRF.sh: $HOST"
			$SCRIPTS/03_SSRF.sh $HOST
	else
			echo -e "Execute 2 03_SSRF.sh: $HOST"
			$SCRIPTS/03_SSRF.sh $HOST
	fi
}

active.CORS()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.CORS [ \$HOST / target.com ]"
	elif [ ! -z "$1" ] ; then
			HOST=$1
			echo -e "Execute 1 04_CORS.sh: $HOST"
			$SCRIPTS/04_CORS.sh $HOST
	else
			echo -e "Execute 2 04_CORS.sh: $HOST"
			$SCRIPTS/04_CORS.sh $HOST
	fi
}

active.REDIRECT()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.REDIRECT [ \$HOST / target.com ]"
	elif [ ! -z "$1" ] ; then
			HOST=$1
			echo -e "Execute 1 05_REDIRECT.sh: $HOST"
			$SCRIPTS/05_REDIRECT.sh $HOST
	else
			echo -e "Execute 2 05_REDIRECT.sh: $HOST"
			$SCRIPTS/05_REDIRECT.sh $HOST
	fi
}

active.SQLi()	{
	if [ $# -lt 1 ] && [ -z "$HOST" ] ; then
			echo "Usage: active.SQLi [ \$HOST / target.com ] [ POST / GET ]"
	elif [ ! -z "$1" ] && [ ! -z "$2" ] ; then
			HOST=$1
			METHOD=$2
			echo -e "Execute 1 06_SQLi.sh: $HOST $METHOD"
			$SCRIPTS/06_SQLi.sh $HOST $METHOD
	else
			HOST=$1
			METHOD=$2
			echo -e "Execute 2 06_SQLi.sh: $HOST $METHOD"
			$SCRIPTS/06_SQLi.sh $HOST $METHOD
	fi
}

#---------------------------------------------------------------------------------------------------------------------------------------
#	ALIASES ----------------------------------------------------------------------------------------------------------------------------

#	dirsearch -u "http://$HOST/" -e "php,html.js"
alias dirsearch='python3 $TOOLS/dirsearch/dirsearch.py'

#---------------------------------------------------------------------------------------------------------------------------------------
#	PATH	----------------------------------------------------------------------------------------------------------------------------

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
source $GOPATH/pkg/mod/github.com/tomnomnom/gf@v0.0.0-20200618134122-dcd4c361f9f5/gf-completion.bash
