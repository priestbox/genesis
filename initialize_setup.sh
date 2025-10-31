#!/bin/bash
#
#	neural.priest
#
#---------------------------------------------------------------------------------------------------------------------------------------
#	initialize_setup.sh	--	priest:	Hope that firewall works because your screwed
#
#	Tested: Debian 13 (trixie)
#---------------------------------------------------------------------------------------------------------------------------------------
#
#	masscan --banners
#	apt-get install ufw
#	sudo cat /proc/sys/net/ipv4/ip_local_port_range
#	32768	60999
#	block single port below or above Linux reserved port range
#	sudo ufw reset
#	sudo ufw deny 61000
#	sudo ufw reload
#	sudo ufw enable
#	sudo ufw status verbose
#
#	Far from complete, though gets enough done quickly

export DEBIAN_FRONTEND=noninteractive;

echo "[*] Starting Install..."
echo -e "\nRunning package upgrade\n"

cd $HOME

sudo apt-get update
sudo apt-get -y upgrade

echo -e	"[*] Done ... [*]\n\n"

if [ ! -f $HOME/.bash_aliases ]; then
	echo	"[*] File $HOME/.bash_aliases not found!"
	: > $HOME/.bash_aliases
	echo	"[*] Aborting installation..."
	exit 1
else
	echo	"[*] Installing .bash_genesis"
	git clone https://github.com/priestbox/genesis.git
	echo -e "[*] Done ... [*]\n\n"
fi

echo -e	"[*] Done ... [*]\n\n"

cd $HOME

echo "[*] Installing OS tools and dependent libraries"

sudo apt-get install -y ufw					# security & masscan firewall --source-port 61000
sudo apt-get install -y jq whois dnsutils curl			# .bash_genesis
sudo apt-get install -y python3-pip python3-setuptools pipx	# pip3, pipx
sudo apt-get install -y make build-essential git		# massdns, masscan
sudo apt-get install -y gcc libpcap-dev				# massdns, masscan
sudo apt-get install -y xsltproc libxml2 libxml2-dev		# xsltproc
sudo apt-get install -y libxml2-utils unzip			# searchsploit --nmap -x <file.xml> && etc...

sudo apt-get install -y php php-common							# inurlbr apache2 php
sudo apt-get install -y libcurl4t64 libcurl4-openssl-dev php8.4 php8.4.cli php8.4-curl	# inurlbr etc...
sudo apt-get install -y hydra								# hydra

echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing Google Chrome"

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb		# google-chrome-stable
# dpkg -i ./google-chrome-stable_current_amd64.deb
# mv google-chrome-stable_current_amd64.deb $HOME/Downloads
# sudo apt-get remove --purge google-chrome-stable

echo -e	"[*] Done ... [*]\n\n"

echo "[*] Manifestation of Python3 enviroment $HOME/.venv"

mkdir -p $HOME/.local/bin
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bash_aliases
source $HOME/.bash_aliases
python3 -m venv $HOME/.venv
source $HOME/.venv/bin/activate

echo -e	"[*] Done ... [*]\n\n"

pipx install uro
sudo apt-get -y install python3-shodan	# pipx/pip3 depreciated
pipx install xsrfprobe
pipx install whatweb
pipx install arjun			# github db-wordlists 
pip3 install mmh3			# mmh3 (shodan hash-favicon)

#	Install go https://go.dev/dl/

if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, would you like to install it now"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)

			echo "Installing Golang"
			wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
			sudo tar -xvf go1.25.0.linux-amd64.tar.gz
			sudo mv go /usr/local
			export GOROOT=/usr/local/go
			export GOPATH=$HOME/go
			export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
			echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_aliases
			echo 'export GOPATH=$HOME/go' >> $HOME/.bash_aliases			
			echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> $HOME/.bash_aliases
			sleep 1
			break
			;;
		no)
			echo "Please install go and rerun this script"
			echo "Aborting installation..."
			exit 1
			;;
	esac	
done
fi

cat $HOME/genesis/insert.db >> $HOME/.bash_aliases
source $HOME/.bash_aliases

echo -e	"[*] Done ... [*]\n\n"

#	Create WORKZONE filesystem

echo "[*] Creating WORKZONE structure"
mkdir -p $HOME/.gf/
mkdir -p $HOME/WORKZONE/
mkdir -p $HOME/WORKZONE/data
mkdir -p $HOME/WORKZONE/data-active
mkdir -p $HOME/WORKZONE/data-raw
mkdir -p $HOME/WORKZONE/tmp
mkdir -p $HOME/WORKZONE/tools
# mkdir -p $HOME/WORKZONE/wordlists		#	/opt/

#	Setup $HOME/initialize_target.sh $HOME/.gf/

cp $HOME/genesis/initialize_target.sh $HOME/WORKZONE/
cp -R $HOME/genesis/.gf/* $HOME/.gf/

chmod 755 $HOME/WORKZONE/initialize_target.sh
chmod -R 744 $HOME/.gf

echo -e	"[*] Done ... [*]\n\n"

#	Load up on tools

cd $HOME/WORKZONE/tools
TOOLS=$HOME/WORKZONE/tools

echo "[*] Installing nmap"
sudo apt-get install -y nmap
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing nmap vulners"
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse -O /usr/share/nmap/scripts/vulners.nse
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/http-vulners-paths.txt -O /usr/share/nmap/nselib/data/http-vulners-paths.txt
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/http-vulners-regex.json -O /usr/share/nmap/nselib/data/http-vulners-regex.json
sudo wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/http-vulners-regex.nse -O /usr/share/nmap/scripts/http-vulners-regex.nse
sudo nmap --script-updatedb
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing masscan"
cd $TOOLS
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make
sudo cp bin/masscan /usr/local/bin/masscan
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing massdns"
cd $TOOLS
git clone https://github.com/blechschmidt/massdns
cd massdns
make
sudo make install
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing metasploit-framework"
cd $TOOLS
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
rm -rf msfinstall
#	$ msfconsole
#	$ db_status
echo -e	"[*] Done ... [*]\n\n"

echo "[*] GO_LANG Binaries"

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/qsreplace@latest
go install github.com/tomnomnom/gron@latest
go install github.com/tomnomnom/meg@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/gf@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/tomnomnom/unfurl@latest
go install github.com/takshal/freq@latest
go install github.com/003random/getJS/v2@latest
go install github.com/lc/subjs@latest
go install github.com/hahwul/dalfox/v2@latest
go install github.com/ffuf/ffuf/v2@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/channyein1337/jsleak@latest


echo 'source $GOPATH/pkg/mod/github.com/tomnomnom/gf@v0.0.0-20200618134122-dcd4c361f9f5/gf-completion.bash' >> $HOME/.bash_aliases	

echo -e	"[*] GO_LANG Binaries Done ... [*]\n\n"

# echo "[*] Installing EyeWtness"
# cd $TOOLS
# git clone https://github.com/FortyNorthSecurity/EyeWitness
# cd EyeWitness/Python/setup
# EDIT: setup.sh -- source /home/user/.venv/bin/activate
# sudo ./setup.sh
# sudo chown $USER:$USER $HOME/.venv/bin/*
# echo -e "[*] Done ... [*]\n\n"

echo "[*] Installing dirsearch"
cd $TOOLS
git clone https://github.com/maurosoria/dirsearch.git --depth 1
cd dirsearch
# source $HOME/.local/bin/activate
pip3 install -r requirements.txt 
ln -s $PWD/dirsearch.py $HOME/.local/bin/dirsearch
echo -e "[*] Done ... [*]\n\n"

echo "[*] Installing arjun - github version"			#	-o JSON_FILE, -oJ JSON_FILE
cd $TOOLS							#	arjun -u https://api.example.com/endpoint [ -m POST ]
git clone https://github.com/s0md3v/Arjun.git			#	arjun -u https://api.example.com/endpoint [ -w /path/to/wordlist.txt ]
# cd Arjun/arjun/db						#	{arjundir}/db/large.txt
echo -e "[*] Done ... [*]\n\n"

echo "[*] Installing SQLMAP"
cd $TOOLS
sudo apt-get install -y sqlmap
echo -e "[*] Done ... [*]\n\n"

#	Minor Tangents

echo "[*] Install INURLBR"
cd $TOOLS
git clone https://github.com/MrCl0wnLab/SCANNER-INURLBR
sudo ln -s $TOOLS/SCANNER-INURLBR/inurlbr /usr/local/bin/inurlbr
sudo chmod +x /usr/local/bin/inurlbr
echo -e "[*] Done ... [*]\n\n"

#	Load up on wordlists 

# LISTS=$HOME/WORKZONE/wordlists
# cd $LISTS

# echo "[*] Installing SecLists"
# cd $LISTS
# git clone https://github.com/danielmiessler/SecLists
# This file breaks MASSDNS and needs to be trimmed
# cd SecLists/Discovery/DNS
# cat dns-Jhaddix.txt | head -n -14 > dns-Jhaddix-cleaned.txt
# double check head output as cmd can fail.
# echo -e	"[*] Done ... [*]\n\n"

#	Load up on exploitdb

echo "[*] Installing ExploitDB"
# cd $LISTS # art-deco
sudo git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Cleanup / Disable"
sudo systemctl disable apache2
sudo systemctl stop apache2
echo -e	"[*] Done ... [*]\n\n"

cd $HOME/WORKZONE
deactivate
source $HOME/.bash_aliases

cd $HOME
mv google-chrome-stable_current_amd64.deb $HOME/WORKZONE/tmp
mv go1.25.0.linux-amd64.tar.gz $HOME/WORKZONE/tmp
sudo apt-get autoremove --purge

echo -e "[*] Execute: sudo chown -R $USER:$USER $HOME/WORKZONE\n\n"
echo -e "[*] Execute: source $HOME/.bashrc to chain various .bash_<scripts> !!\n\n"

echo -e "[*] Finished Setup Installation\n\n"

# ===============================================================================================
# ===============================================================================================
# EOF