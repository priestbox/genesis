#!/bin/bash
#
#-------------------------------------------------------------------------------------------------------------------------------------------
#	initialize_setup.sh	--	priest:	Hope that firewall works because your screwed
#
#	Tested: Debian 12 (bookworm)
#-------------------------------------------------------------------------------------------------------------------------------------------
#
#	masscan --banners
#	apt-get install ufw
#	sudo cat /proc/sys/net/ipv4/ip_local_port_range
#	32768	60999
#	block single port below or above Linux reserved port range
#	sudo ufw deny 61000
#	sudo ufw enable
#	sudo ufw status verbose
#
#	Far from complete, though gets enough done quickly

export DEBIAN_FRONTEND=noninteractive;

echo "[*] Starting Install..."
echo -e "\nRunning package upgrade\n"

cd ~/

sudo apt-get update
sudo apt-get -y upgrade

echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing OS tools and dependent libraries"

sudo apt-get install -y ufw									# security & masscan firewall --source-port 61000
sudo apt-get install -y jq whois dnsutils curl				# .bash_aliases
sudo apt-get install -y python3-pip python3-setuptools		# pip3
sudo apt-get install -y make build-essential git			# massdns, masscan
sudo apt-get install -y gcc libpcap-dev						# massdns, masscan
sudo apt-get install -y xsltproc libxml2 libxml2-dev		# xsltproc
sudo apt-get install -y unzip								# etc...

# sudo apt-get install -y php php-common														# inurlbr
# sudo apt-get install -y libcurl4 libcurl4-openssl-dev php8.2 php8.2.cli php8.2-curl			# inurlbr etc...

echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc

pip3 install uro
pip3 install shodan
pip3 install arjun
pip3 install xsrfprobe

echo -e	"[*] Done ... [*]\n\n"

if [ ! -f ~/.bashrc ]; then
	echo	"[*] File ~/.bashrc not found!"
	echo	"[*] Aborting installation..."
	exit 1
else
	echo	"[*] Installing .bash_aliases"
	git clone https://github.com/priestbox/genesis.git
	cp genesis/.bash_aliases ~/.bash_aliases
	source ~/.bash_aliases								# source ~/.bashrc
	echo -e "[*] Done ... [*]\n\n"
fi

#	Install go https://go.dev/dl/

if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, would you like to install it now"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)

					echo "Installing Golang"
					wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
					sudo tar -xvf go1.24.3.linux-amd64.tar.gz
					sudo mv go /usr/local
					export GOROOT=/usr/local/go
					export GOPATH=$HOME/go
					export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
					echo 'export GOROOT=/usr/local/go' >> ~/.bash_aliases
					echo 'export GOPATH=$HOME/go' >> ~/.bash_aliases			
					echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_aliases	
					source ~/.bash_aliases
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


#	Create WORKSPACE filesystem

echo "[*] Creating WORKSPACE structure"
mkdir -p ~/.gf/
mkdir -p ~/WORKSPACE/
mkdir -p ~/WORKSPACE/modules
mkdir -p ~/WORKSPACE/PAYLOADS
mkdir -p ~/WORKSPACE/rawdata
mkdir -p ~/WORKSPACE/scripts
mkdir -p ~/WORKSPACE/tools
mkdir -p ~/WORKSPACE/wordlists

#	Setup ./initialize_target.sh ~/.gf/ modules/ PAYLOADS/ scripts/

cp ~/genesis/initialize_target.sh ~/WORKSPACE/
cp ~/genesis/.gf/* ~/.gf/
cp ~/genesis/modules/* ~/WORKSPACE/modules/
cp ~/genesis/PAYLOADS/* ~/WORKSPACE/PAYLOADS/
cp ~/genesis/scripts/* ~/WORKSPACE/scripts/

chmod 755 ~/WORKSPACE/initialize_target.sh
chmod -R 744 ~/.gf
chmod -R 744 ~/WORKSPACE/PAYLOADS

# rm -rf ~/genesis

echo -e	"[*] Done ... [*]\n\n"

#	Load up on tools

cd ~/WORKSPACE/tools

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
git clone https://github.com/robertdavidgraham/masscan
cd masscan
make
sudo cp bin/masscan /usr/local/bin/masscan
cd ~/WORKSPACE/tools
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing massdns"
git clone https://github.com/blechschmidt/massdns
cd massdns
make
sudo make install
cd ~/WORKSPACE/tools
echo -e	"[*] Done ... [*]\n\n"

#	echo "[*] Installing metasploit-framework"
#	curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
#	rm -rf msfinstall
#	$ msfconsole
#	$ db_status
#	echo -e	"[*] Done ... [*]\n\n"

echo "[*] GO_LANG Binaries"

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/qsreplace@latest
go install github.com/tomnomnom/gron@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/gf@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/tomnomnom/unfurl@latest
go install github.com/sensepost/gowitness@latest
go install github.com/takshal/freq@latest
go install github.com/ffuf/ffuf/v2@latest 
go install github.com/003random/getJS/v2@latest
go install github.com/lc/subjs@latest
go install github.com/hahwul/dalfox/v2@latest

echo 'source $GOPATH/pkg/mod/github.com/tomnomnom/gf@v0.0.0-20200618134122-dcd4c361f9f5/gf-completion.bash' >> ~/.bash_aliases	

echo -e	"[*] Done ... [*]\n\n"

echo "[*] EyeWitness"
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd EyeWitness/Python/setup
sudo ./setup.sh
cd ~/WORKSPACE/tools
echo -e "[*] Done ... [*]\n\n"

echo "[*] Installing dirsearch"
git clone https://github.com/maurosoria/dirsearch
cd dirsearch
pip3 install -r requirements.txt 
cd ~/WORKSPACE/tools
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing SQLMAP"
sudo apt-get install -y sqlmap
echo -e "[*] Done ... [*]\n\n"

#	Minor Tangents

# echo "[*] Install INURLBR"
# git clone https://github.com/MrCl0wnLab/SCANNER-INURLBR
# sudo ln -s ~/WORKSPACE/tools/SCANNER-INURLBR/inurlbr /usr/local/bin/inurlbr
# sudo chmod +x /usr/local/bin/inurlbr
# echo -e "[*] Done ... [*]\n\n"

#	Load up on wordlists 

cd ~/WORKSPACE/wordlists

echo "[*] Installing fuzzdb"
git clone https://github.com/fuzzdb-project/fuzzdb
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing wfuzz"
sudo apt-get install -y wfuzz
ln -s /usr/share/wfuzz/wordlist/ wfuzzdb
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Installing SecLists"
git clone https://github.com/danielmiessler/SecLists
# This file breaks MASSDNS and needs to be trimmed
# cd SecLists/Discovery/DNS
# cat dns-Jhaddix.txt | head -n -14 > dns-Jhaddix-cleaned.txt
# double check head output as cmd can fail.
echo -e	"[*] Done ... [*]\n\n"

cd ~/WORKSPACE

#	Load up on exploitdb

echo "[*] Installing ExploitDB"
sudo git clone https://gitlab.com/exploit-database/exploitdb.git /opt/exploitdb
sudo ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit
echo -e	"[*] Done ... [*]\n\n"

echo "[*] Cleanup / Disable"
sudo systemctl disable apache2
sudo systemctl stop apache2
echo -e	"[*] Done ... [*]\n\n"

# chown -R user:user ~/WORKSPACE

echo -e "[*] Execute: chown -R user:user ~/WORKSPACE\n\n"
echo -e "[*] Execute: source ~/.bashrc !!!\n"
echo -e "[*] Execute: source ~/.bash_aliases\n\n"

echo -e "[*] Finished Setup Installation\n\n"
