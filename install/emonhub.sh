#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "Install EmonHub"
echo "-------------------------------------------------------------"
cd $openenergymonitor_dir

if [ ! -d $openenergymonitor_dir/emonhub ]; then
    git clone -b $emonhub_branch ${git_repo[emonhub]}
else 
    echo "- emonhub repository already installed"
    git -C $openenergymonitor_dir/emonhub pull
fi

if [ -f $openenergymonitor_dir/emonhub/install.sh ]; then
    if [ -f $seal_dir/lib/defaults/emonhub.conf ]; then
        if [ ! -d /etc/emonhub ]; then
            sudo mkdir /etc/emonhub
        fi
        sudo cp $seal_dir/lib/defaults/emonhub.conf /etc/emonhub/emonhub.conf
    fi
    $openenergymonitor_dir/emonhub/install.sh $emonSD_pi_env
else
    echo "ERROR: $openenergymonitor_dir/emonhub/install.sh script does not exist"
fi

# Sudoers entry (review!)
sudo visudo -cf $emonscripts_dir/sudoers.d/emonhub-sudoers && \
sudo cp $emonscripts_dir/sudoers.d/emonhub-sudoers /etc/sudoers.d/
sudo chmod 0440 /etc/sudoers.d/emonhub-sudoers
echo "EmonHUB service control sudoers entry installed"
