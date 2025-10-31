#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------------------
#		06_EYEWITNESS.sh --all-protocols || --web (Default)
#
#		Tested: Debian 13 (trixie)
#-------------------------------------------------------------------------------------------------------------------------------------------

#		HOST=$HOST # xargs placeholder

		echo "[*]	Running: 06_EYEWITNESS.sh on httpx.alive.db --web" 

		source ~/.venv/bin/activate

		python3 $HOME/WORKZONE/tools/EyeWitness/Python/EyeWitness.py --prepend-https -f httpx.alive.db -d $PWD/data-enumeration/eyewitness --no-prompt --timeout 120 --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
		rm $PWD/geckodriver.log

		deactivate
#		echo -e "\n"