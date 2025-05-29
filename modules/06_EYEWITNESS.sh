#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		06_EYEWITNESS.sh --all-protocols || --web (Default)
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 06_EYEWITNESS.sh on 02.HTTPROBE.ALIVE.lst --web" 

	python3 ~/WORKSPACE/tools/EyeWitness/Python/EyeWitness.py --prepend-https -f 02.HTTPROBE.ALIVE.lst -d $PWD/eyewitness --no-prompt --timeout 120 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
	rm geckodriver.log

echo -e "\n"