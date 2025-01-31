#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "Install Emoncms Core Modules"
echo "-------------------------------------------------------------"
# Review default branch: e.g stable
cd $emoncms_www/Modules
if [ -v emoncms_modules[@] ]; then
    for module in ${!emoncms_modules[@]}; do
        branch=${emoncms_modules[$module]}
        if [ ! -d $module ]; then
            echo "- Installing module: $module"
            git clone -b $branch ${git_repo[$module]} $module
        else
            echo "- Module $module already exists"
        fi
    done
fi

# Install emoncms modules that do not reside in /var/www/emoncms/Modules
if [ -v symlinked_emoncms_modules[@] ]; then
	if [ ! -d $emoncms_dir/modules ]; then
	    sudo mkdir -p $emoncms_dir/modules
	    sudo chown $user -R $emoncms_dir
	fi
    cd $emoncms_dir/modules

    for module in ${!symlinked_emoncms_modules[@]}; do
        branch=${symlinked_emoncms_modules[$module]}
        if [ ! -d $module ]; then
            echo "- Installing module: $module"
            git clone -b $branch ${git_repo[$module]}
            # If module contains emoncms UI folder, symlink to $emoncms_www/Modules
            if [ -d $emoncms_dir/modules/$module/$module-module ]; then
                echo "-- UI directory symlink"
                ln -s $emoncms_dir/modules/$module/$module-module $emoncms_www/Modules/$module
            fi
            # run module install script if present
            if [ -f $emoncms_dir/modules/$module/install.sh ]; then
                $emoncms_dir/modules/$module/install.sh $openenergymonitor_dir
                echo
            fi
        else
            echo "- Module $module already exists"
        fi
    done
fi
echo "Update Emoncms database"
php $emonscripts_dir/common/emoncmsdbupdate.php
