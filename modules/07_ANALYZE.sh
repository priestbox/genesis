#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		07_ANALYZE.sh -- Set user permissions .. id || id -u
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------

#		HOST=$HOST # xargs placeholder

		echo -e "[*]	Running: 		07_ANALYZE.sh on $HOST Directory Structures and Cache flush\n" 

		find $HOME/WORKZONE/data-active/$HOST/. -type d -print0 | xargs -0 sudo chown -R $USER:$USER

##		Use at own RISK, however helps when there is 10's of thousands of output files, mostly empty bloat to search through
#		ls -lSrh $HOME/WORKZONE/data-active/$HOST/nmap-data/ 		# Sizing files, determines bloat file sizes
#		ls -lSrh $HOME/WORKZONE/data-active/$HOST/nmap-data/ | wc -l	# Total count
#		sleep 5
#		find $HOME/WORKZONE/data-active/$HOST/nmap-data/. -type f -size -10k -exec rm -v {} \;	# Deletion of bloat files less than 10k (1024 B per k)
#		rm -rf $HOME/WORKZONE/data-active/$HOST/split
##		EOF sub-routine

#		echo -e "\n"

		echo -e "[*]	Initialized Target: 	$HOST\n"
		echo -e "[*]	Execute Scanning:	08_ACTIVE.sh"

#EOF
