# armbian-hass
Home Assistant image for OrangePi 2 based on Armbian.

# Installation
- Follow building Armbian guide: https://docs.armbian.com/Developer-Guide_Build-Preparation to clone git repo
- After repo is cloned, edit `userpatches/customize-image.sh` and put:
   ```shell
   wget -O /tmp/customize-image-hass.sh https://raw.githubusercontent.com/rufik/armbian-hass/master/customize-image-hass.sh
   chmod ugo+x /tmp/customize-image-hass.sh
   bash -c /tmp/customize-image-hass.sh
   ```
   It will perform customization with HASSIO and Home Assistant installation with Docker.
- After image is built just burn it into SD CARD and run your OrangePI SBC.
 
# Running
When your OPI is up&running just login via ssh and perform:
```shell
sudo systemctl start hassio-supervisor.service
sudo docker-compose -f /etc/docker/docker-compose-portainer.yml up -d
```
Then go to http://<ip>:9000 for Portainer, you should see portainer and hassio supervisor containers running. Start home-assistant container also.

Voila!
 