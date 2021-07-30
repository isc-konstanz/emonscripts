#!/bin/bash

user=$USER
emonscripts_dir=/opt/oem/emonscripts

sudo mkdir -p $(dirname "$emonscripts_dir")

sudo apt-get update
sudo apt-get install -y git-core

sudo git clone -b seal https://github.com/isc-konstanz/emonscripts.git $emonscripts_dir
sudo chown $user -R $emonscripts_dir

cd $emonscripts_dir/install
bash ./main.sh

cd
rm -f $(readlink -f "${BASH_SOURCE[0]}")
