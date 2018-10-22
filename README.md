# armbian-hass
This is customization script for Home Assistant installation on Armbian distro.
Tested on OrangePI 2 and OrangePI PC.

# Installation
- Execute commands:
   ```shell
   wget -O /tmp/customize-image-hass.sh https://raw.githubusercontent.com/rufik/armbian-hass/master/customize-image-hass.sh
   chmod ug+x /tmp/customize-image-hass.sh
   sudo /tmp/customize-image-hass.sh
   ```
   or use -h option to set hostname:
   ```shell
   sudo /tmp/customize-image-hass.sh -h opi2
   ```
   It will perform customization with Home Assistant installation using Docker.
- After that machine restart is required if the hostname is changed.
 
# Running
When your OPI is up&running just login via ssh and perform:
```shell
sudo docker-compose -f /etc/docker/docker-compose-portainer.yml up -d
```
Then go to http://<ip>:9000 for Portainer, you should see portainer with containers. Start them one by one: mqtt, influxdb, grafana, home-assistant.

Voila!
 