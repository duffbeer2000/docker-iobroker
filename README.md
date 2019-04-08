## ioBroker Docker Image

[![Build Status](https://travis-ci.org/duffbeer2000/iobroker.svg?branch=master)](https://travis-ci.org/duffbeer2000/iobroker)

This Docker image containerizes the ioBroker software from ioBroker GmbH. ioBroker is an integration platform for the Internet of Things, focused on Building Automation, Smart Metering, Ambient Assisted Living, Process Automation, Visualization and Data Logging.

ioBroker is supported on `amd64`, `armv7hf` (i.e. RaspberryPi 2/3), and `aarch64` architectures.

This image is available on (and should be pulled from) Docker Hub: `duffbeer2000/iobroker`.

Current ioBroker version: **2.0.2**

### Running the ioBroker Container

#### Command Line

```bash
docker run -d \
    --name=iobroker \
    --net=host \
    --restart=always \
    --v /etc/localtime:/etc/localtime:ro \
    --v /your/iobroker/folder:/opt/iobroker \
    duffbeer2000/iobroker
```

#### Command line Options

|Parameter|Description|
|---------|-----------|
|`--name=iobroker`|Names the container "iobroker".|
|`--net=host`|Uses host networking mode; by default, the web UIs listen on port 8081. If these port conflict with other services on your host, you can change it through the environment variables IOBROKER_WEB_PORT described below.|
|`--restart=always`|Start the container when Docker starts (i.e. on boot/reboot).|
|`-v /etc/localtime:/etc/localtime:ro`|Ensure the container has the correct local time (alternatively, use the TZ environment variable, see below).|
|`-v /your/iobroker/folder:/opt/iobroker`|Bind mount /your/iobroker/folder (or the directory of your choice) into the container for persistent storage.|
|`duffbeer2000/iobroker`|This image uses a manifest list for multiarch support; specifying duffbeer2000/iobroker (i.e. duffbeer2000/iobroker:latest) will pull the correct version for your arch.|

#### Environment Variables

Use these environment variables to change the default behaviour of the container.

|Parameter|Description|
|---------|-----------|
|`-e LANG=de_DE.UTF-8`|Set the local time zone so iobroker has the correct time.|
|`-e TZ=Europe/Berlin`|Set the local time zone so iobroker has the correct time.|
|`-e IOBROKER_ADMIN_PORT=8081`|By default, the admin UI listen on port 8081; only set this environment variable if you wish to change the listen port.|
|`-e IOBROKER_WEB_PORT=8082`|By default, the web UI listen on port 8082; only set this environment variable if you wish to change the listen port.|
|`-e AVAHI=0`|Will install and activate avahi-daemon for supporting yahka-adapter.|
|`-e BT_ENABLE=0`|Only available with the full images. Enables bluetooth support.|
|`-e ASTERISK=0`|Only available with the full images. Enables asterisk support.|
||1 = ioBroker & asterisk running on same server with ffmpeg|
||2 = ioBroker & asterisk running on same server with sox|
||3 = ioBroker & asterisk running on different server with ffmpeg|
||4 = ioBroker & asterisk running on different server with sox|

#### Docker-Compose

A docker-compose.yml file is provided in the root of this image's GitHub repo. You may also copy/paste the following into your existing docker-compose.yml, modifying the options as required (omit the `version` and `services` lines as your docker-compose.yml will already contain these).

```yaml
version: "2"
services:
  iobroker:
    image: duffbeer2000/iobroker
    container_name: iobroker
    network_mode: host
    restart: always
    volumes:
      - /your/iobroker/folder:/opt/iobroker
    environment:
      - LANG=de_DE.UTF-8
      - TZ=Europe/Berlin
      - IOBROKER_ADMIN_PORT=8081
      - IOBROKER_WEB_PORT=8082
      - AVAHI=0
      - BT_ENABLE=0
      - ASTERISK=0
```

Then, you can do `docker-compose pull` to pull the latest duffbeer2000/iobroker image, `docker-compose up -d` to start the iobroker container service, and `docker-compose down` to stop the iobroker service and delete the container. Note that these commands will also pull, start, and stop any other services defined in docker-compose.yml.

#### Running on Docker for Mac / Docker for Windows

The `--net=host` option is not yet supported on Mac/Windows. To run this container on those platforms, explicitly specify the ports in the run command and omit `--net=host`:

```bash
docker run -d \
    --name=iobroker \
    -p 8081:8081 \
    -p 8082:8082 \
    --restart=always \
    -v /your/iobroker/folder:/opt/iobroker \
    -e IOBROKER_ADMIN_PORT=8081 \
    -e IOBROKER_WEB_PORT=8082 \
    marthoc/deconz
```

### Tags
|TAG|Description|
|---------|-----------|
|`latest`|Multiarch standard image, corrects false permissions of the ioBroker directory.|
|`full`|Multiarch full image, scans the ioBroker directory for known adapter dependencies and corrects false permissions of the ioBroker directory.|
|`min`|Multiarch minimal image, you have to look for everything on your own.|
|`X.X.X|Same as latest above but with fixed image version, so there is no update till you change it.|
|`full-X.X.X|Same as full but with fixed image version, so there is no update till you change it.|
|`min-X.X.X|Same as min but with fixed image version, so there is no update till you change it.|
|`X.X.X-*architecture*|Same as above but with fixed image version and fixed architecture, so there is no update till you change it.|
|`full-X.X.X-*architecture*|Same as above but with fixed image version and fixed architecture, so there is no update till you change it.|
|`min-X.X.X-*architecture*|Same as above but with fixed image version and fixed architecture, so there is no update till you change it.|
|`amd64`|Standard image for amd64 achitecture, corrects false permissions of the ioBroker directory.|
|`armv7hf`|Standard image for armv7hf achitecture, corrects false permissions of the ioBroker Directory.|
|`aarch64`|Standard image for aarch64 achitecture, corrects false permissions of the ioBroker Directory.|
|`full-amd64`|Full image for amd64 achitecture, scans the ioBroker directory for known adapter dependencies and corrects false permissions of the ioBroker directory.|
|`full-armv7hf`|Full image for armv7hf achitecture, scans the ioBroker directory for known adapter dependencies and corrects false permissions of the ioBroker directory.|
|`full-aarch64`|Full image for aarch64 achitecture, scans the ioBroker directory for known adapter dependencies and corrects false permissions of the ioBroker directory.|
|`min-amd64`|Minimal image for amd64 achitecture, you have to look for everything on your own.|
|`min-armv7hf`|Minimal image for armv7hf achitecture, you have to look for everything on your own.|
|`min-aarch64`|Minimal image for aarch64 achitecture, you have to look for everything on your own.|


### Features of the different versions standard(latest), full and min 
latest:
	- Set AVAHI to 1 for yahka support
	- Set IOBROKER_ADMIN_PORT to change the port of the admin adapter
	- Set IOBROKER_WEB_PORT to change the port of the web adapter
	- If a file with the name "UPGRADE" is detected in the iobroker folder the startup script runs a "npm rebuild" in the ioBroker folder. Only do this if you restore a ioBroker folder which was installed with a npm version prior to v8.
	- If a file with the name "pre_script.sh" is detected in the iobroker folder the startup script makes it runable and starts it
	- If a file with the name "custom_packages.list" is detected in the iobroker folder it installs all packages in the file
	- If a file with the name "post_script.sh" is detected in the iobroker folder the startup script makes it runable and starts it
	- If a file with NPM_UPGRADE_TRIGGER="/opt/iobroker/REINSTALL"
	- before it starts ioBroker it corrects file and folder permissions for ioBroker
	- starts ioBroker with the iobroker user

full:
	- The full version scans all installed adapters and installs all known dependencies (if there is something missing or not longer needed please open an issue on github)
	- Set AVAHI enable avahi support. If yahka adapter is installed avahi gets enabled automatically
	- Set IOBROKER_ADMIN_PORT to change the port of the admin adapter
	- Set IOBROKER_WEB_PORT to change the port of the web adapter
	- Set BT_ENABLE to 1if you have a bluetooth stick or something like that installed
	- Set ASTERISK to:
		1 = ioBroker & asterisk running on same server with ffmpeg
		2 = ioBroker & asterisk running on same server with sox
		3 = ioBroker & asterisk running on different server with ffmpeg
		4 = ioBroker & asterisk running on different server with sox
	- If a file with the name "UPGRADE" is detected in the iobroker folder the startup script runs a "npm rebuild" in the ioBroker folder. Only do this if you restore a ioBroker folder which was installed with a npm version prior to v8.
	- If a file with the name "pre_script.sh" is detected in the iobroker folder the startup script makes it runable and starts it
	- If a file with the name "custom_packages.list" is detected in the iobroker folder it installs all packages in the file
	- If a file with the name "post_script.sh" is detected in the iobroker folder the startup script makes it runable and starts it
	- If a file with NPM_UPGRADE_TRIGGER="/opt/iobroker/REINSTALL"
	- before it starts ioBroker it corrects file and folder permissions for ioBroker
	- starts ioBroker with the iobroker user
	
min: 	
	- Minimal version, is running fine too but needs a little bit more work
	- Set AVAHI enable avahi support. If yahka adapter is installed avahi gets enabled automatically
	- Set IOBROKER_ADMIN_PORT to change the port of the admin adapter
	- Set IOBROKER_WEB_PORT to change the port of the web adapter
	- starts ioBroker with the iobroker user	

### Gotchas / Known Issues
At the moment I'm testing the language and timezone settings. Maybe they don't work as expecting at the moment.

### Issues / Contributing

Please raise any issues with this container at its GitHub repo: https://github.com/duffbeer2000/docker-iobroker. Please check the "Gotchas / Known Issues" section above before raising an Issue on GitHub in case the issue is already known.

To contribute, please fork the GitHub repo, create a feature branch, and raise a Pull Request; for simple changes/fixes, it may be more effective to raise an Issue instead.

### Building Locally

Pulling `duffbeer2000/iobroker` from Docker Hub is the recommended way to obtain this image. However, you can build this image locally by:

```bash
git clone https://github.com/duffbeer2000/docker-iobroker.git
cd dockertravis
docker build -t "[your-user/]iobroker[:local]" ./[arch]
```

|Parameter|Description|
|---------|-----------|
|`[your-user/]`|Your username (optional).|
|`iobroker`|The name you want the built Docker image to have on your system (default: iobroker).|
|`[local]`|Adds the tag `:local` to the image (to help differentiate between this image and your locally built image) (optional).|
|`[arch]`|The architecture you want to build for (currently supported options: `amd64` and `armhf`).|

### Acknowledgments

ioBroker GmbH for making ioBroker.

@buanet for his iobroker container from which I was inspired: https://github.com/buanet/docker-iobroker.