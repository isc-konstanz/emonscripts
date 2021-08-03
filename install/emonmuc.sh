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

cp -fp  $emonscripts_dir/defaults/emonmuc/emoncms.conf $openmuc_dir/conf/emoncms.conf
sed -i "s/MYSQL_USERNAME/$mysql_user/"                 $openmuc_dir/conf/emoncms.conf
sed -i "s/MYSQL_PASSWORD/$mysql_password/"             $openmuc_dir/conf/emoncms.conf
sed -i "s/MQTT_USER/$mqtt_user/"                       $openmuc_dir/conf/emoncms.conf
sed -i "s/MQTT_PASSWORD/$mqtt_password/"               $openmuc_dir/conf/emoncms.conf

if [ "$setup_init" = true ]; then
    emonmuc_port_key="org.osgi.service.http.port"
    emonmuc_port=`grep -m 1 $emonmuc_port_key $openmuc_dir/conf/system.properties | sed "s/${emonmuc_port_key}.*=//;s/^[ \t]*//g"`

    php $emonscripts_dir/install/emonmuc.php --dir "$emoncms_www" --port "$emonmuc_port"
fi
