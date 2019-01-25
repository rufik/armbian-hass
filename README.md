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
   or use -d option to customize docker bridge network address:
   ```shell
   sudo /tmp/customize-image-hass.sh -h opi2 -d 192.168.7.1/24
   ```
   It will perform customization with Home Assistant installation using Docker.
- After that machine restart is required if the hostname is changed.
 
# Running
When your OPI is up&running, Portainer should be already running - go to http://<ip>:9000 and check it. If not then just login via ssh and perform:
```shell
sudo docker-compose -f /etc/docker/docker-compose-portainer.yml up -d
```
Then go to http://<ip>:9000 for Portainer, you should see portainer with containers. Start them one by one: mariadb, mqtt, influxdb, grafana. Then do some configuration prior to start Home Assistant:
- create db on mariadb, ie.: https://www.ibm.com/support/knowledgecenter/en/SSGSCT_9.1.3/install_guide/pac_createdbschema_mysql_noha.html (pay attention to secure admin access to mariadb also!)
- create db on influx, ie: https://docs.influxdata.com/influxdb/v1.7/introduction/getting-started/#creating-a-database
- adjust mosquitto access if needed (login+passwd)
- adjust configuration.yaml for proper access to mariadb, influxdb and mqtt

When you're ready, then just start Home Assistant container using Portainer.
Voila!
 