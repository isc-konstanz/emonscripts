#!/bin/bash
pwgen_installed=$(dpkg -l | grep -q -e pwgen)

setup_dir=/home/$user/.setup
if [ ! -d $setup_dir ]; then
    mkdir -p $setup_dir
fi

passwd_file=$setup_dir/passwd.conf
touch "$passwd_file"

if ! grep -q "^\[Debian\]$" $passwd_file; then
    echo "[Debian]" >> $passwd_file
    echo "$user:raspberry" >> $passwd_file
fi

if [ "$install_mysql" = true ]; then
    if ! grep -q "^\[MySQL\]$" $passwd_file; then
        echo -e "\n[MySQL]" >> $passwd_file
    fi
    if grep -A3 -P "^\[MySQL\]$" $passwd_file | grep -m1 -q "root"; then
        mysql_root=`grep -A3 -P "^\[MySQL\]$" $passwd_file | grep -m1 "root:" |\
                    sed "s/root://g" | sed -r "s/\s+//g"`
    else
        mysql_root=""
        echo "root:" >> $passwd_file
    fi
    if grep -A3 -P "^\[MySQL\]$" $passwd_file | grep -m1 -q "$mysql_user"; then
        mysql_password=`grep -A3 -P "^\[MySQL\]$" $passwd_file | grep -m1 "$mysql_user:" |\
                        sed "s/$mysql_user://g" | sed -r "s/\s+//g"`
    elif $pwgen_installed; then
		mysql_password=$(pwgen -s1 32)
        echo "$mysql_user:$mysql_password" >> $passwd_file
    fi
fi
if [ "$install_mosquitto" = true ]; then
    if ! grep -q "^\[MQTT\]$" $passwd_file; then
        echo -e "\n[MQTT]" >> $passwd_file
    fi
    if grep -A3 -P "^\[MQTT\]$" $passwd_file | grep -m1 -q "$mqtt_user"; then
        mqtt_password=`grep -A3 -P "^\[MQTT\]$" $passwd_file | grep -m1 "$mqtt_user:" |\
                        sed "s/$mqtt_user://g" | sed -r "s/\s+//g"`
    elif $pwgen_installed; then
        mqtt_password=$(pwgen -s1 32)
        echo "$mqtt_user:$mqtt_password" >> $passwd_file
    fi
fi

if [ "$setup_init" = true ]; then
    if ! grep -q "^\[Emoncms\]$" $passwd_file; then
        echo -e "\n[Emoncms]" >> $passwd_file
    fi
    emoncms_user="admin"

    if grep -A3 -P "^\[Emoncms\]$" $passwd_file | grep -m1 -q "$emoncms_user"; then
        emoncms_password=`grep -A3 -P "^\[Emoncms\]$" $passwd_file | grep -m1 "$emoncms_user:" |\
                        sed "s/$emoncms_user://g" | sed -r "s/\s+//g"`
    elif $pwgen_installed; then
        emoncms_password=$(pwgen -s1 10)
        echo "$emoncms_user:$emoncms_password" >> $passwd_file
    fi
fi
