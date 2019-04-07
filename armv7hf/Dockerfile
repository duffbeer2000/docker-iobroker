FROM balenalib/armv7hf-debian:stretch

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
	libavahi-compat-libdnssd-dev \
	libpam0g-dev \
	libudev-dev \
	locales \
	procps \
	python \
	# https://forum.iobroker.net/viewtopic.php?t=10920
	python-dev\
	sudo \
	# Install nano and net-tools for debugging
	nano \
	net-tools \
 && rm -rf /var/lib/apt/lists/*


## Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \
 && apt-get install -y nodejs \
 && rm -rf /var/lib/apt/lists/* \
 ## Set language and timezone
 && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
 && \dpkg-reconfigure --frontend=noninteractive locales \
 && \update-locale LANG=de_DE.UTF-8 \
 && cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
 
#https://hub.docker.com/_/debian/
#https://github.com/docker-library/postgres/blob/69bc540ecfffecce72d49fa7e4a46680350037f9/9.6/Dockerfile#L21-L24
#RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
#    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
#ENV LANG en_US.utf8

## Create the neccessary folders and set access rights
RUN mkdir -p /opt/scripts \
 && chmod 777 /opt/scripts

## ioBroker installation
RUN echo $(hostname) > /opt/scripts/.install_host \
 && sudo apt-get update \
 ##ATTENTION THIS IS A TEMPORARY WORKAROUND TILL THE BUG IS FIXED
 && npm config set unsafe-perm true \
 ##ATTENTION THIS IS A TEMPORARY WORKAROUND TILL THE BUG IS FIXED
 && curl -sL https://iobroker.net/install.sh | bash - \
 && sudo rm -rf /var/lib/apt/lists/*

## Install Node.js native addon build tool
WORKDIR /opt/iobroker/
RUN sudo npm install node-gyp -g \
 && sudo tar -cf /opt/initial_iobroker.tar -C / opt/iobroker \
 ##ATTENTION THIS IS A TEMPORARY WORKAROUND TILL THE BUG IS FIXED
 && npm config set unsafe-perm false
 ##ATTENTION THIS IS A TEMPORARY WORKAROUND TILL THE BUG IS FIXED

## Add necessary scripts
COPY scripts /opt/scripts

# Set scripts executable
RUN chmod -R +x /opt/scripts

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
	IOBROKER_WEB_PORT="8082"

CMD ["bash", "/opt/scripts/iobroker_startup.sh"]
