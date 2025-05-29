#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		07_ANALYZE.sh -- Set user permissions .. id || id -u
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 07_ANALYZE.sh on $HOST Directory structures" 

	find ~/WORKSPACE/rawdata/$HOST -type d -print0 | xargs -0 sudo chown -R user:user

echo -e "\n"

echo "[*]	Finished Target: $HOST Initialization\n"

#EOF
