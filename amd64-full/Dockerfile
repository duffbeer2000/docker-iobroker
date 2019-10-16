FROM debian:latest

MAINTAINER Christian

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

## Install necessary packages
RUN apt-get update && apt-get install -y \
	apt-utils \
	build-essential \
	curl \
	git \
	gnupg2 \
	gosu \
	libavahi-compat-libdnssd-dev \
	libpam0g-dev \
	libudev-dev \
	locales \
	procps \
	python \
	# https://forum.iobroker.net/viewtopic.php?t=10920
	python-dev\
	sudo \
 && rm -rf /var/lib/apt/lists/*


## Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash \
 && apt-get update && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/* \ 
 ## Set language and timezone
 && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
 && \dpkg-reconfigure --frontend=noninteractive locales \
 && \update-locale LANG=de_DE.UTF-8 \
 && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

## Create the neccessary folders and set access rights
RUN mkdir -p /opt/scripts \
 && mkdir -p /opt/maintenance_scripts \
 && chmod 777 /opt/scripts \
 && chmod 777 /opt/maintenance_scripts

## ioBroker installation
RUN echo $(hostname) > /opt/scripts/.install_host \
 && apt-get update \
 && curl -sL https://iobroker.net/install.sh | bash - \
 ## install jq to get installed adapters
 && apt-get install -y jq \
 && rm -rf /var/lib/apt/lists/*

## Install Node.js native addon build tool
WORKDIR /opt/iobroker/
RUN npm install node-gyp -g \
 && node -v > /opt/scripts/.dockernodeversion \
 && nodejs -v > /opt/iobroker/.dockernodejsversion \
 && npm -v > /opt/scripts/.dockernpmversion \
 && tar -cf /opt/initial_iobroker.tar -C / opt/iobroker

## Add necessary scripts
COPY maintenance_scripts /opt/maintenance_scripts
COPY scripts /opt/scripts

# Set scripts executable
RUN chmod +x /opt/scripts/iobroker_startup.sh \
 && chmod +x /opt/scripts/avahi_startup.sh \
 && chmod +x /opt/maintenance_scripts/enable_multihost.sh \
 && chmod +x /opt/maintenance_scripts/iobroker_stop.sh
 
# Exposed Ports
# 8081 iobroker admin
# 8082 iobroker vis
# 8083 flot
# 8084 socketIO
# 8088 terminal
# 9000 Multihost
# 9001 Multihost
# 50005 Multihost

EXPOSE 8081 8082 8083 8084 8088 9000 9001 50005

ENV LANG="de_DE.UTF-8" \
    TZ="Europe/Berlin" \
	AVAHI="0" \
	IOBROKER_ADMIN_PORT="8081" \
	IOBROKER_WEB_PORT="8082" \
	BT_ENABLE="0" \
	ASTERISK="0"

CMD ["bash", "/opt/scripts/iobroker_startup.sh"]
