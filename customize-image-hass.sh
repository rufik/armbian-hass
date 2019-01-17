#!/bin/bash

# from https://github.com/armbian/build/blob/master/lib/general.sh
print_info()
{
  echo "Displaying message: $@" >> hass_customizer.log
  local tmp=""
  [[ -n $2 ]] && tmp="[\e[0;33m $2 \x1B[0m]"

  case $3 in
    err)
    echo -e "[\e[0;31m error \x1B[0m] $1 $tmp"
    ;;

    warn)
    echo -e "[\e[0;35m warn \x1B[0m] $1 $tmp"
    ;;

    ext)
    echo -e "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp"
    ;;

    info)
    echo -e "[\e[0;32m o.k. \x1B[0m] $1 $tmp"
    ;;

    *)
    echo -e "[\e[0;32m info \x1B[0m] $1 $tmp"
    ;;
  esac
}

if [ $(id -u) != 0 ]; then
	print_info "This script has to be run as root!" "" "err"
	exit 1
fi


#some variables
BASE_DIR="/opt/has"
DOCKER_COMPOSE_DIR="${BASE_DIR}"

print_info "******** -< Starting HASS customization >- ********" "" "ext"
#user creation is armbian's first run feature

#fix improper min cpu freq for H3
print_info "Patching cpufrequtils min speed for H3..."
sed -i 's/408000/480000/g' /etc/default/cpufrequtils
service cpufrequtils restart
print_info "Disabling unattended-upgrades service..."
systemctl stop unattended-upgrades
systemctl disable unattended-upgrades

print_info "Updating OS..."
apt-get -q update && apt-get -y upgrade

#make sure that OS upgrade does not recover faulty min cpu freq
print_info "Patching cpufrequtils min speed for H3 (after OS upgrade)..."
sed -i 's/408000/480000/g' /etc/default/cpufrequtils
service cpufrequtils restart
print_info "Disabling unattended-upgrades service (after OS upgrade)..."
systemctl stop unattended-upgrades
systemctl disable unattended-upgrades

print_info "Installing required packages and armbianmonitor..."
apt-get -q -y install mc ccze jq avahi-daemon screen telnet
armbianmonitor -r

print_info "Setting red LED as hearbeat on system start ..."
sed -i 's/exit 0//g' /etc/rc.local
echo 'RESULT=`echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger`' >> /etc/rc.local
echo 'exit 0' >> /etc/rc.local

while getopts ":h:" opt; do
	case "$opt" in
	h)
		print_info "Setting hostname '$OPTARG' ..."
		hostname $OPTARG
		echo "$OPTARG" > /etc/hostname
	;;
	\?)
		print_info "Invalid option: -$OPTARG. Skipping." "" "warn"
		;;
	:)
		print_info "Option -$OPTARG requires an argument. Skipping" "" "warn"
		;;
	esac
done


print_info "Installing Docker CE ..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -q update
apt-get -q -y install docker-ce docker-compose
systemctl enable docker
print_info "" "Done." "info"

print_info "Adding user 'has'..."
useradd -m has
print_info "Setting password for user has - you will be prompted for password!"
passwd has

print_info "Preparing folders in $BASE_DIR"
mkdir -p $BASE_DIR/config
mkdir -p $BASE_DIR/addons
mkdir -p $BASE_DIR/mqtt/data
mkdir -p $BASE_DIR/mqtt/logs
mkdir -p $BASE_DIR/mqtt/conf
mkdir -p $BASE_DIR/influxdb
mkdir -p $BASE_DIR/mariadb/data
mkdir -p $BASE_DIR/mariadb/config
#chmod ug+rwx $BASE_DIR/mqtt/logs/

print_info "Downloading MQTT config files..."
wget -q -O /$BASE_DIR/mqtt/conf/options.json https://raw.githubusercontent.com/rufik/armbian-hass/master/mqtt/options.json
wget -q -O $BASE_DIR/mqtt/conf/mosquitto.conf https://raw.githubusercontent.com/rufik/armbian-hass/master/mqtt/mosquitto.conf
#prevent mosquitto from overwriting config file
chmod ugo-w $BASE_DIR/mqtt/conf/mosquitto.conf
#wget -O /opt/has/addons/configurator-settings.conf https://raw.githubusercontent.com/rufik/armbian-hass/master/addons/configurator-settings.conf
print_info "" "Done." "info"

print_info "Downloading HASS, MariaDB and InfluxDB config files..."
wget -q -O $BASE_DIR/influxdb/influxdb.conf https://raw.githubusercontent.com/rufik/armbian-hass/master/influxdb/influxdb.conf
wget -q -O $BASE_DIR/config/configuration.yaml https://raw.githubusercontent.com/rufik/armbian-hass/master/hass/configuration.yaml
wget -q -O $BASE_DIR/mariadb/config/my.cnf https://raw.githubusercontent.com/rufik/armbian-hass/master/mariadb/my.cnf
touch $BASE_DIR/config/groups.yaml
touch $BASE_DIR/config/automations.yaml
touch $BASE_DIR/config/scripts.yaml
touch $BASE_DIR/config/customize.yaml
touch $BASE_DIR/config/secrets.yaml
print_info "" "Done." "info"


print_info "Downloading docker-compose files into $DOCKER_COMPOSE_DIR dir..."
wget -q -O $DOCKER_COMPOSE_DIR/docker-compose-portainer.yml https://raw.githubusercontent.com/rufik/armbian-hass/master/docker-compose-portainer.yml
wget -q -O $DOCKER_COMPOSE_DIR/docker-compose-hass.yml https://raw.githubusercontent.com/rufik/armbian-hass/master/docker-compose-hass.yml
print_info "" "Done." "info"

HAS_UID=`id -u has`
print_info "Patching docker-compose files using 'has' user UID=$HAS_UID"
sed -i -e 's\user: has\user: "$HAS_UID"\g' $DOCKER_COMPOSE_DIR/docker-compose-hass.yml
print_info "" "Done." "info"

#set user "has" as owner
chown -R has.root $BASE_DIR/

print_info "Pulling & creating docker images..."
docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-portainer.yml pull
docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-hass.yml pull
docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-portainer.yml up --no-start
docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-hass.yml up --no-start
print_info "" "Done." "info"

#echo "Starting Portainer..."
#docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-portainer.yml up -d
#echo "Done."

print_info "******** -< End of HASS customization >- ********" "" "ext"
HOSTNAME=`hostname -s`
print_info "It's preferred to reboot your machine and then start Portainer. You can find it using your browser at http://$HOSTNAME:9000"
print_info "You can start Portainer by command: sudo docker-compose -f $DOCKER_COMPOSE_DIR/docker-compose-portainer.yml up -d"
echo ""
