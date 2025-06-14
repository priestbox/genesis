#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		06_EYEWITNESS.sh --all-protocols || --web (Default)
#-------------------------------------------------------------------------------------------------------------------------------------------

echo "[*]	Running: 06_EYEWITNESS.sh on 02.HTTPROBE.ALIVE.lst --web" 

	python3 $HOME/WORKZONE/tools/EyeWitness/Python/EyeWitness.py --prepend-https -f 02.HTTPROBE.ALIVE.lst -d $PWD/eyewitness --no-prompt --timeout 120 --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
	rm geckodriver.log

echo -e "\n"