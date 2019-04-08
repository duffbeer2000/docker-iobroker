#!/bin/bash

#Reading ENV-Variables
avahi=$AVAHI
ADMIN_PORT=$IOBROKER_ADMIN_PORT
WEB_PORT=$IOBROKER_WEB_PORT
bluetooth_enabled=$BT_ENABLE
asterisk=$ASTERISK
yahka="false"

#Declarate variables
version="0.7.0"
IOB_USER="iobroker"
IOB_DIR="/opt/iobroker"
HOSTNAME_NEW=$(hostname)
PACKAGELIST="/opt/iobroker/custom_packages.list"
PRE_SCRIPT="/opt/iobroker/pre_script.sh"
POST_SCRIPT="/opt/iobroker/post_script.sh"
REINSTALL_TRIGGER="/opt/iobroker/RUNREINSTALL"

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
install_package_linux() {
	package="$1"
	echo "Installing $package"
	if [ "$IS_ROOT" = true ]; then
		apt-get install -yq $package > /dev/null 2>&1
	else
		sudo apt-get install -yq $package > /dev/null 2>&1
	fi
	echo "Installed $package"
}

array_contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

scan_adapter_dependencies() {
	echo ''
	echo 'Scanning known dependencies of installed adapters...'
	# First try to get all installed Adapters
	INSTALLED_ADAPTERS=( $(cat /opt/iobroker/package.json | jq '[.dependencies | objects | keys[]] | unique' | sed '1d;$d;s/"//g;s/,//g;s/ //g'))
	# echo ${INSTALLED_ADAPTERS[@]}
	for adapter in "${INSTALLED_ADAPTERS[@]}"; do
		case "$adapter" in
			"iobroker.amazon-dash")
				# https://github.com/PArns/ioBroker.amazon-dash
				echo 'ioBroker.amazon-dash Adapter detected, adding dependend packages'
				adapter_packages+=('libpcap-dev')
				;;
			"iobroker.asterisk")
				# https://github.com/schmupu/ioBroker.asterisk
				echo 'ioBroker.asterisk Adapter detected, adding dependend packages'
				case "$asterisk" in
					"1")
						#Linux Packages / ioBroker & asterisk running on same server with ffmpeg
						adapter_packages+=('ffmpeg')
						adapter_packages+=('asterisk')
						;;
					"2")
						#Linux Packages / ioBroker & asterisk running on same server with sox
						adapter_packages+=('lame')
						adapter_packages+=('sox')
						adapter_packages+=('libsox-fmt-mp3')
						adapter_packages+=('asterisk')
						;;
					"3")
						#Linux Packages / ioBroker on asterisk running on different server with ffmpeg
						adapter_packages+=('ffmpeg')
						adapter_packages+=('openssh-client')
						;;

					"4")
						#Linux Packages / ioBroker on asterisk running on different server with sox
						adapter_packages+=('lame')
						adapter_packages+=('sox')
						adapter_packages+=('libsox-fmt-mp3')
						adapter_packages+=('openssh-client')
						;;
					*)
						;;
				esac
				;;
			"iobroker.backitup")
				# https://github.com/simatec/ioBroker.backitup/blob/master/docs/de/backitup.md
				echo 'ioBroker.backitup Adapter detected, adding dependend packages'
				adapter_packages+=('cifs-utils')
				adapter_packages+=('nfs-common')
				;;
			"iobroker.ble")
				# https://github.com/AlCalzone/ioBroker.ble
				echo 'ioBroker.ble Adapter detected, adding dependend packages'
				adapter_packages+=('bluetooth')
				adapter_packages+=('bluez')
				adapter_packages+=('libbluetooth-dev')
				;;
			"iobroker.firetv")
				# https://github.com/soef/ioBroker.firetv
				echo 'ioBroker.firetv Adapter detected, adding dependend packages'
				adapter_packages+=('android-tools-adb')
				adapter_packages+=('android-tools-fastboot')
				;;
			"iobroker.hid")
				# https://github.com/soef/ioBroker.hid
				echo 'ioBroker.hid Adapter detected, adding dependend packages'
				adapter_packages+=('libusb-1.0-0-dev')
				;;
			"iobroker.mysensors")
				# https://github.com/ioBroker/ioBroker.mysensors
				echo 'ioBroker.mysensors Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				adapter_packages+=('python2.7')
				;;
			"iobroker.owfs")
				# https://github.com/ioBroker/ioBroker.owfs
				echo 'ioBroker.owfs Adapter detected, adding dependend packages'
				adapter_packages+=('owfs')
				;;
			"iobroker.phantomjs")
				# https://github.com/ioBroker/ioBroker.phantomjs
				echo 'ioBroker.phantomjs Adapter detected, adding dependend packages'
				adapter_packages+=('libfontconfig')
				;;
			"iobroker.radar")
				# https://github.com/frankjoke/ioBroker.radar
				# Add Arp-scan, hcitool oder l2ping to sudo without password
				echo 'ioBroker.radar Adapter detected, adding dependend packages'
				adapter_packages+=('fping')
				adapter_packages+=('arp-scan')
				# install following if Bluetooth is enabled
				if [ "$bluetooth_enabled" = "1" ]; then
					adapter_packages+=('bluetooth')
					adapter_packages+=('bluez')
					adapter_packages+=('libbluetooth-dev')
					adapter_packages+=('libudev-dev')
					adapter_packages+=('libcap2-bin')
				fi
				;;
			"iobroker.rflink")
				# https://github.com/ioBroker/ioBroker.rflink
				echo 'ioBroker.rflink Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				;;
			"iobroker.roomba")
				# https://github.com/Zefau/ioBroker.roomba
				echo 'ioBroker.roomba Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				adapter_packages+=('libcairo2-dev')
				adapter_packages+=('libpango1.0-dev')
				adapter_packages+=('libjpeg-dev')
				adapter_packages+=('libgif-dev')
				adapter_packages+=('librsvg2-dev')
				;;
			"iobroker.rpi2")
				# https://github.com/ioBroker/ioBroker.rpi2
				echo 'ioBroker.rpi2 Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				adapter_packages+=('python')
				;;
			"iobroker.s7")
				# https://github.com/ioBroker/ioBroker.s7
				echo 'ioBroker.s7 Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				;;
			"iobroker.sayit")
				# https://github.com/ioBroker/ioBroker.sayit
				echo 'ioBroker.sayit Adapter detected, adding dependend packages'
				adapter_packages+=('mpg321')
				;;
			"iobroker.smartmeter")
				# https://github.com/Apollon77/ioBroker.smartmeter
				echo 'ioBroker.smartmeter Adapter detected, adding dependend packages'
				adapter_packages+=('git')
				;;
			"iobroker.snips")
				# https://github.com/Bettman66/ioBroker.snips
				echo 'ioBroker.snips Adapter detected, adding dependend packages'
				sed -i 's:stretch main:stretch non-free main:g'  /etc/apt/sources.list
				sed -i 's:stretch/updates main:stretch/updates non-free main:g'  /etc/apt/sources.list
				sed -i 's:stretch-updates main:stretch-updates non-free main:g'  /etc/apt/sources.list
				adapter_packages+=('lsb-release')
				adapter_packages+=('apt-transport-https')
				adapter_packages+=('ca-certificates')
				adapter_packages+=('systemd')
				adapter_packages+=('systemd-sysv')
				adapter_packages+=('libttspico-utils')
				adapter_packages+=('alsa-utils')
				adapter_packages+=('dirmngr')
				adapter_packages+=('mosquitto')
				adapter_packages+=('snips-asr')
				adapter_packages+=('snips-audio-server')
				adapter_packages+=('snips-dialogue')
				adapter_packages+=('snips-hotword')
				adapter_packages+=('snips-nlu')
				adapter_packages+=('snips-tts')
				adapter_packages+=('snips-injection')
				;;				
			"iobroker.tradfri")
				# https://github.com/AlCalzone/ioBroker.tradfri
				echo 'ioBroker.tradfri Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				;;
			"iobroker.yahka")
				# https://github.com/jensweigele/ioBroker.yahka/wiki/Installation-and-Troubleshooting
				echo 'ioBroker.yahka Adapter detected, adding dependend packages'
				adapter_packages+=('libavahi-compat-libdnssd-dev')
				adapter_packages+=('pam-devel')
				avahi="1"
				yahka="true"
				;;
			"iobroker.xbox")
				# https://github.com/foxriver76/ioBroker
				echo 'ioBroker.xbox Adapter detected, adding dependend packages'
				adapter_packages+=('build-essential')
				adapter_packages+=('libssl-dev')
				adapter_packages+=('libffi-dev')
				adapter_packages+=('python3-dev')
				;;			
			"iobroker.zigbee")
				# https://github.com/ioBroker/ioBroker.zigbee
				echo 'ioBroker.zigbee Adapter detected, adding dependend packages'
				adapter_packages+=('udev')
				;;
			"iobroker.zwave")
				# https://github.com/ioBroker/ioBroker.zwave
				echo 'ioBroker.zwave Adapter detected, adding dependend packages'
				adapter_packages+=('pkg-config')
				adapter_packages+=('libudev-dev')
				adapter_packages+=('build-essential')
				adapter_packages+=('curl')
				adapter_packages+=('unzip')
				;;
			*)
				;;
		esac
	done
	
	for packages in "${adapter_packages[@]}"; do
	if [ $(array_contains "${missing_packages[@]}" "$packages") == "n" ]; then
		dpkg -s "$packages" &> /dev/null
		if [ $? -ne 0 ]; then
			# Install it
			missing_packages+=("$packages")
		fi	
	fi
	done
	
	if [ ${#missing_packages[@]} -ne 0 ]; then
		echo ''
		echo "Missing packages to install: ${missing_packages[@]}"
		if [ "$IS_ROOT" = true ]; then
			apt-get update > /dev/null
			missingstring="${missing_packages[@]}"
			apt-get -y install $missingstring > /dev/null 2>&1
		else
			sudo apt-get update > /dev/null
			missingstring="${missing_packages[@]}"
			sudo apt-get -y install $missingstring > /dev/null 2>&1
		fi
	
	else
		echo ''
		echo "All dependencies are already installed..."
	fi
}

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

pre_script() {
	echo ''
	echo 'Pre-Start Script found - Running the Pre-Script...'
	if [ "$IS_ROOT" = true ]; then
		bash $PRE_SCRIPT
	else
		sudo bash $PRE_SCRIPT
	fi
	echo 'Finished running the Pre-Start Script...'
}

post_script() {
	echo ''
	echo 'Post-Start Script found - Running the Post-Start...'
	if [ "$IS_ROOT" = true ]; then
		bash $POST_SCRIPT
	else
		sudo bash $POST_SCRIPT
	fi
	echo 'Finished running the Post-Start Script...'
}

packagelist_file() {
	echo ''
	echo 'Packagelist found - Install custom packages if missing...'
	OLDIFS=$IFS
	IFS=$'\r\n' GLOBIGNORE='*' command eval  'packages=($(cat $PACKAGELIST))'
	IFS=$OLDIFS
	for pkg in "${packages[@]}"; do
		echo $pkg
		install_package_linux $pkg
	done
	echo 'Finished install of custom packages...'
}

packagelist_env() {
	echo ''
	echo 'Packagelist Environment found - Install custom packages if missing...'
	OLDIFS=$IFS
	IFS=','
	for package in ${INSTALL_PACKAGES}; do
		IFS=$OLDIFS
		install_package_linux $package
	done
	echo 'Finished install of custom packages...'
}

cleanup_aptcache() {
	# Cleanup apt-cache
	echo ''
	echo "Cleanup apt-cache..."
	if [ "$IS_ROOT" = true ]; then
		sudo rm -rf /var/lib/apt/lists/*
	else
		rm -rf /var/lib/apt/lists/*
	fi
}

reinstall_iobroker() {
# Reinstall iobroker if Reinstall Trigger is found
	echo ''
	echo 'Reinstall trigger found! - Running the Reinstall-Script...'
	cd /opt/iobroker
	bash ./reinstall.sh
	rm $REINSTALL_TRIGGER
	echo 'Finished running the Reinstall-Script...'
}

change_owner() {
	user="$1"
	file="$2"
	owner="$user:$user"
	cmdline="chown"
	if [ -d $file ]; then
		# recursively chown directories
		cmdline="$cmdline -R"
	elif [ -L $file ]; then
		# change ownership of symbolic links
		cmdline="$cmdline -h"
	fi
	$cmdline $owner $file
}

fix_dir_permissions() {
	# Give the user access to all necessary directories
	echo ''
	echo "Fixing directory permissions..."
	# ioBroker install dir
	change_owner $IOB_USER $IOB_DIR
	# and the npm cache dir
	if [ -d "/home/$IOB_USER/.npm" ]; then
		change_owner $IOB_USER "/home/$IOB_USER/.npm"
	fi
	# Give the iobroker group write access to all files by setting the default ACL
	setfacl -Rdm g:$IOB_USER:rwx $IOB_DIR &> /dev/null && setfacl -Rm g:$IOB_USER:rwx $IOB_DIR &> /dev/null
	if [ $? -ne 0 ]; then
		# We cannot rely on default permissions on this system
		echo "${yellow}This system does not support setting default permissions.${normal}"
		echo "${yellow}Do not use npm to manually install adapters unless you know what you are doing!${normal}"
	fi
}

modify_user_permissions() {
	username=$IOB_USER
	# Add the user to all groups we need and give him passwordless sudo privileges
	# Define which commands iobroker may execute as sudo without password
	declare -a iob_commands=(
		"shutdown -h now" "halt" "poweroff" "reboot"
		"systemctl start" "systemctl stop"
		"mount" "umount" "systemd-run"
		"apt-get" "apt" "dpkg" "make"
		"ping" "fping"
		"arp-scan"
		"setcap"
		"vcgencmd"
		"cat"
		"df"
	)

	SUDOERS_CONTENT="$username ALL=(ALL) ALL\n"
	for cmd in "${iob_commands[@]}"; do
		# Test each command if and where it is installed
		cmd_bin=$(echo $cmd | cut -d ' ' -f1)
		cmd_path=$(which $cmd_bin 2> /dev/null)
		if [ $? -eq 0 ]; then
			# Then add the command to SUDOERS_CONTENT
			full_cmd=$(echo "$cmd" | sed -e "s|$cmd_bin|$cmd_path|")
			SUDOERS_CONTENT+="$username ALL=(ALL) NOPASSWD: $full_cmd\n"
		fi
	done

	SUDOERS_FILE="/etc/sudoers.d/iobroker"
	if [ "$IS_ROOT" = true ]; then
		rm -f $SUDOERS_FILE
		echo -e "$SUDOERS_CONTENT" > ~/temp_sudo_file
		visudo -c -q -f ~/temp_sudo_file && \
			chown root:$ROOT_GROUP ~/temp_sudo_file &&
			chmod 440 ~/temp_sudo_file &&
			mv ~/temp_sudo_file $SUDOERS_FILE &&
			echo ''
			echo "Created $SUDOERS_FILE"
	fi

	# Add the user to all groups if they exist
	declare -a groups=(
		bluetooth
		dialout
		gpio
		i2c
		redis
		tty
	)
	for grp in "${groups[@]}"; do
		if [ "$IS_ROOT" = true ]; then
			getent group $grp &> /dev/null && usermod -a -G $grp $username
		else
			getent group $grp &> /dev/null && sudo usermod -a -G $grp $username
		fi
	done
}

set_capabilities() {
	#Check the capabilities of the Container
	capabilities=$(grep ^CapBnd /proc/$$/status)
	capabilities_encoded=${capabilities:(-16)}
	capabilities_decoded=$(capsh --decode=${capabilities_encoded})
	
	# Check if the whole Devices are mounted or maybe the Container is started privilegded
	if [[ "${capabilities_encoded}" == "0000003fffffffff" ]]; then
		${red}
		echo ''
		echo "ATTENTION: !!!THE CONTAINER IS RUNNING PRIVILEDGED!!!"
		echo "ATTENTION: This is very unsecure and should therefore be avoided!"
		echo "ATTENTION: !!!THE CONTAINER IS RUNNING PRIVILEDGED!!!"
		${normal}
	fi


	capabilities=$(grep ^CapBnd /proc/$$/status)
	if [[ ${capabilities_decoded} == *"cap_net_admin"* ]]; then
		setcap 'cap_net_admin,cap_net_bind_service,cap_net_raw+eip' $(eval readlink -f `which node`)
	else
		setcap 'cap_net_bind_service,cap_net_raw+eip' $(eval readlink -f `which node`)
		${yellow}
		echo ''
		echo "If you have any adapters that need the CAP_NET_ADMIN capability,"
		echo "you need to start the docker container with the option --cap-add=NET_ADMIN"
		echo "and manually add that capability to node${normal}"
	fi
}


# Information
echo ''
echo '----------------------------------------'
echo '---- Image-Version: '$version'-Full ----'
echo '-----      '$dati'      -----'
echo '----------------------------------------'
echo ''
echo 'Startupscript running...'
# Show installed Node- and NPM-Version
echo "Node-Version:   " $(node -v)
echo "NodeJs-Version: " $(nodejs -v)
echo "Npm-Version:    " $(npm -v)

# Give nodejs access to protected ports and raw devices like ble
set_capabilities

# Restoring if ioBroker-folder empty
cd /opt/iobroker
if [ `ls -1a|wc -l` -lt 3 ]; then
	restore_iobroker_folder
fi

# Check if installation is updated or new
if [ -f /opt/scripts/.install_host ]; then
	first_run_prep
fi

# Scan Dependencies of the installed Adapters
scan_adapter_dependencies

# Checking for and setting up avahi-daemon
if [ "$avahi" = "1" ]; then
	avahi_init $yahka
fi

# Run Pre-Start script if exist
if [ -f $PRE_SCRIPT ]; then
	pre_script
fi

# Install additional packages if packagelist exist
if [ -f $PACKAGELIST ]; then
	packagelist_file
fi

# Install additional packages if packagelist environment variable exist
if [ ! -z "${INSTALL_PACKAGES}" ]; then
	packagelist_env
fi

# Run Post-Start script if exist
if [ -f $POST_SCRIPT ]; then
	post_script
fi

if [ -f $REINSTALL_TRIGGER ]; then
	reinstall_iobroker
fi

# Cleanup apt-cache
cleanup_aptcache

# Check Permissions and correct it
modify_user_permissions

check_permissions=$(ls -l -R /opt/iobroker | awk '{print $3}')
if [[ $check_permissions == *"root"* ]]; then
	fix_dir_permissions
fi	
check_permissions=$(ls -l -R /opt/iobroker | awk '{print $4}')
if [[ $check_permissions == *"root"* ]]; then
	fix_dir_permissions
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