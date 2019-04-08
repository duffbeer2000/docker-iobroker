#!/bin/bash

#Reading ENV-Variables
avahi=$AVAHI
ADMIN_PORT=$IOBROKER_ADMIN_PORT
WEB_PORT=$IOBROKER_WEB_PORT

#Declarate variables
version="0.7.0"
IOB_USER="iobroker"
IOB_DIR="/opt/iobroker"
HOSTNAME_NEW=$(hostname)

# Getting date and time for logging 
dati=`date '+%Y-%m-%d %H:%M:%S'`

# Enable colored output
if test -t 1; then # if terminal
	ncolors=$(which tput > /dev/null && tput colors) # supports color
	if test -n "$ncolors" && test $ncolors -ge 8; then
		termcols=$(tput cols)
		bold="$(tput bold)"
		underline="$(tput smul)"
		standout="$(tput smso)"
		normal="$(tput sgr0)"
		black="$(tput setaf 0)"
		red="$(tput setaf 1)"
		green="$(tput setaf 2)"
		yellow="$(tput setaf 3)"
		blue="$(tput setaf 4)"
		magenta="$(tput setaf 5)"
		cyan="$(tput setaf 6)"
		white="$(tput setaf 7)"
	fi
fi

#Check if actual user is root
if [[ $EUID -eq 0 ]]; then
	#echo 'Is Root'
	IS_ROOT=true
else
	#echo 'Is not root'
	IS_ROOT=false
fi

# Functions
avahi_init() {
	# Setting up avahi-daemon
	echo ''
	echo 'Initializing Avahi-Daemon...'
	sudo bash /opt/scripts/avahi_startup.sh $1
	echo 'Initializing Avahi-Daemon done...'
}

restore_iobroker_folder() {
	# Restoring ioBroker-folder
	echo ''
	echo 'Directory /opt/iobroker is empty!'
	echo 'Restoring...'
	tar -xf /opt/initial_iobroker.tar -C /
	echo 'Restoring done...'
	
}

first_run_prep() {
	HOSTNAME_OLD=$(cat /opt/scripts/.install_host)
	echo ''
	echo 'First run preparation! Used Hostname:' $(hostname)
	echo 'Renaming ioBroker...'
	iobroker host $(cat /opt/scripts/.install_host)
	rm -f /opt/scripts/.install_host
	echo 'ioBroker renamed...'
	echo 'First run preparation done...'
}

# Information
echo ''
echo '----------------------------------------'
echo '---- Image-Version: '$version'-Min  ----'
echo '-----      '$dati'      -----'
echo '----------------------------------------'
echo ''
echo 'Startupscript running...'
# Show installed Node- and NPM-Version
echo "Node-Version:   " $(node -v)
echo "NodeJs-Version: " $(nodejs -v)
echo "Npm-Version:    " $(npm -v)

# Restoring if ioBroker-folder empty
cd /opt/iobroker
if [ `ls -1a|wc -l` -lt 3 ]; then
	restore_iobroker_folder
fi

# Check if installation is updated or new
if [ -f /opt/scripts/.install_host ]; then
	first_run_prep
fi

# Checking for and setting up avahi-daemon
if [ "$avahi" = "1" ]; then
	avahi_init
fi

if [[ ${ADMIN_PORT} != *"8081"* ]]; then
	cd /opt/iobroker
	iobroker set admin.0 --port ${ADMIN_PORT}
fi

if [[ ${WEB_PORT} != *"8082"* ]]; then
	cd /opt/iobroker
	iobroker set web.0 --port ${WEB_PORT}
fi

# Starting ioBroker
echo ''
echo 'Starting ioBroker...'
cd /opt/iobroker
sudo -H -u iobroker node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker.log 2>&1 & >/opt/scripts/docker_iobroker.log 2>&1 &
echo 'ioBroker started...'

# Preventing container restart
tail -f /dev/null