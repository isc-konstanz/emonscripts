#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "Install EmonMUC"
echo "-------------------------------------------------------------"

emonmuc_dir="/opt/emonmuc"
openmuc_dir="/opt/openmuc"

if [ ! -d $emonmuc_dir ]; then emonmuc_dir=$openenergymonitor_dir/emonmuc; fi
if [ ! -d $emonmuc_dir ]; then
    sudo git clone -b $emonmuc_branch ${git_repo[emonmuc]} $emonmuc_dir
    sudo chown $user -R $emonmuc_dir
else
    echo "EmonMUC framework already installed"
    git -C $emonmuc_dir pull
fi
sudo bash $emonmuc_dir/setup.sh --emoncms $emoncms_www

sudo cp -f $emonscripts_dir/defaults/emonmuc/emoncms.conf $openmuc_dir/conf/emoncms.conf

sudo sed -i "s/MYSQL_DATABASE/$mysql_timeseries/"         $openmuc_dir/conf/emoncms.conf

sudo sed -i "s/MYSQL_USER/$mysql_user/"                   $openmuc_dir/conf/emoncms.conf
sudo sed -i "s/MYSQL_PASSWORD/$mysql_password/"           $openmuc_dir/conf/emoncms.conf

sudo sed -i "s/MQTT_USER/$mqtt_user/"                     $openmuc_dir/conf/emoncms.conf
sudo sed -i "s/MQTT_PASSWORD/$mqtt_password/"             $openmuc_dir/conf/emoncms.conf

openmuc_user=`stat -c "%U" "$openmuc_dir"/bin/openmuc`

if [ "$setup_init" = true ]; then
    openmuc_port_key="org.osgi.service.http.port"
    openmuc_port=`grep -m 1 $openmuc_port_key $openmuc_dir/conf/system.properties | sed "s/${openmuc_port_key}.*=//;s/^[ \t]*//g"`

    # Wait a while for the server to be available.
    # TODO: Explore necessity. May be necessary for Raspberry Pi V1
    printf "Waiting for openmuc service\nPlease wait"

    wait=0
    while ! nc -z localhost $openmuc_port && [ $wait -lt 60 ]; do
        wait=$((wait + 3))
        sleep 3
        printf "."
    done
    while [ $wait -lt 9 ]; do
        wait=$((wait + 3))
        sleep 3
        printf "."
    done
    printf "\n"

    sudo php $emonscripts_dir/install/emonmuc.php --dir="$emoncms_www" --port="$openmuc_port"
fi
sudo chown $openmuc_user -R "$openmuc_dir"/conf
sudo systemctl restart openmuc.service
