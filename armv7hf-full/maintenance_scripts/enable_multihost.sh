#!/bin/bash

secret=$1
cd /opt/iobroker
printf "$secret\n$secret\n" | iobroker multihost enable
cd /opt/iobroker
pkill io
sleep 5
node node_modules/iobroker.js-controller/controller.js >/opt/scripts/docker_iobroker_log.txt 2>&1 &
/bin/bash

exit 0
