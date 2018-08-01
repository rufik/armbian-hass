#!/bin/bash

echo "******** -< Starting HASS customization >- ********"

#user creation is armbian's first run feature

#how to avoid question about decision of config files?
apt-get update && apt-get -y upgrade

# reboot here if kernel has changed?

echo "Installing required packages ..."
apt-get -y install mc ccze jq avahi-daemon screen
armbianmonitor -r

echo "Setting red LED as hearbeat on system start ..."
sed -i 's/exit 0//g' /etc/rc.local
echo 'RESULT=`echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger`' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

echo "Setting hostname 'opi2' ..."
hostname opi2
echo 'opi2' >> /etc/hostname


echo "Installing Docker CE ..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce docker-compose

echo "Installing HASSIO Supervisor ..."
wget -O /tmp/hassio_install.sh https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install.sh
chmod ugo+x /tmp/hassio_install.sh
bash -c '/tmp/hassio_install.sh -m armhf'

echo "Pulling Portainer, Home Assistant and Mosquitto images ..."
mkdir -p /opt/has/config
mkdir -p /opt/has/mqtt/data
mkdir -p /opt/has/mqtt/logs
wget -O /etc/docker/docker-compose-portainer.yml https://raw.githubusercontent.com/rufik/armbian-hass/master/docker-compose-portainer.yml
wget -O /etc/docker/docker-compose-hass.yml https://raw.githubusercontent.com/rufik/armbian-hass/master/docker-compose-hass.yml
wget -O /etc/docker/docker-compose-mqtt.yml https://raw.githubusercontent.com/rufik/armbian-hass/master/docker-compose-mqtt.yml
#docker-compose -f /etc/docker/docker-compose-portainer.yml pull
docker-compose -f /etc/docker/docker-compose-hass.yml pull
docker-compose -f /etc/docker/docker-compose-mqtt.yml pull

echo "Creating Portainer, Home Assistant and Mosquitto containers ..."
#docker-compose -f /etc/docker/docker-compose-portainer.yml create
docker-compose -f /etc/docker/docker-compose-hass.yml create
docker-compose -f /etc/docker/docker-compose-mqtt.yml create

echo "Starting Portainer..."
docker-compose -f /etc/docker/docker-compose-portainer.yml up -d
echo "Done."

echo "******** -< End of HASS customization >- ********"
echo ""
