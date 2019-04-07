#!/bin/bash

echo 'Checking avahi-daemon installation state...'

if [ -f /usr/sbin/avahi-daemon ]
then
	echo 'Avahi already installed...'
else
	echo 'Installing avahi-daemon...'
	apt-get update > /opt/scripts/avahi_startup.log 2>&1
	apt-get install -y libavahi-compat-libdnssd-dev avahi-daemon >> /opt/scripts/avahi_startup.log 2>&1
	rm -rf /var/lib/apt/lists/* >> /opt/scripts/avahi_startup.log 2>&1
	echo 'Configuring avahi-daemon...'
	sed -i '/^rlimit-nproc/s/^\(.*\)/#\1/g' /etc/avahi/avahi-daemon.conf
	echo 'Configuring dbus...'
	mkdir /var/run/dbus/
fi


echo 'Deleting /var/run/avahi-daemon/pid if exists...'
rm -f /var/run/avahi-daemon/pid
	
AVAHI_DAEMON_STATUS=$(/etc/init.d/avahi-daemon status)
echo $AVAHI_DAEMON_STATUS

DAEMON_RUNNING='Daemon is running'
if [[ "$AVAHI_DAEMON_STATUS" == *"$DAEMON_RUNNING"* ]];
then
	echo 'Stopping Avahi mDNS/DNS-SD daemon...'
	/etc/init.d/avahi-daemon stop
	echo 'Deleting /var/run/dbus/pid if exists...'
	rm -f /var/run/dbus/pid
	echo 'Deleting /var/run/avahi-daemon/pid if exists...'
	rm -f /var/run/avahi-daemon/pid
else
	echo 'Deleting /var/run/dbus/pid if exists...'
	rm -f /var/run/dbus/pid

fi

echo 'Configure D-Bus message bus daemon...'
dbus-daemon --system

sleep 5

echo 'Starting avahi-daemon...'

echo $(/etc/init.d/avahi-daemon start)

echo $(/etc/init.d/avahi-daemon status)

exit 0