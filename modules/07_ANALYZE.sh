#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		07_ANALYZE.sh -- Set user permissions .. id || id -u
#-------------------------------------------------------------------------------------------------------------------------------------------

#		00_ANALYZE.sh

		export HOST=$HOST # xargs placeholder
		echo "[*]	Running: 07_ANALYZE.sh on $HOST Directory structures and clean-up of bloat" 

		find $HOME/WORKZONE/rawdata/$HOST/. -type d -print0 | xargs -0 sudo chown -R $USER:$USER

##		Use at own RISK, however helps when there is 10's of thousands of output files, mostly empty bloat to search through

#		ls -lSrh $HOME/WORKZONE/rawdata/$HOST/nmap-data/ 		# Sizing files, determines bloat file sizes
#		ls -lSrh $HOME/WORKZONE/rawdata/$HOST/nmap-data/ | wc -l	# Total count
#		sleep 5
#		find $HOME/WORKZONE/rawdata/$HOST/nmap-data/. -type f -size -10k -exec rm -v {} \;		# Deletion of bloat files less than 10k (1024 B per k)

#		rm -rf $HOME/WORKZONE/rawdata/$HOST/split

##		EOF sub-routine

#		echo -e "\n"

		echo "[*]	Finished Target: $HOST Initialization\n"

#EOF
