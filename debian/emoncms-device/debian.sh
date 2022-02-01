#!/bin/bash
#Description: Build script to generate the emoncms debian package
if [ ! -d $build_tmp/emoncms-device ]; then
    git clone -b ${emoncms_modules[device]} ${git_repo[device]} $build_tmp/emoncms-device
else
    git -C $build_tmp/emoncms-device pull
fi
if [ -f "$build_tmp/emoncms-device/module.json" ]; then
    package_vers=$(cat "$build_tmp/emoncms-device/module.json" | jq -r '.version')
else
    echo "Unable to find module version file"
    exit 1
fi
package_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
package_name="$(basename "$package_path")"
package_id="$package_name"-"$package_vers"
package_build="$build_dir/$package_id"

mkdir -p $package_build

cp -r $defaults_dir/debian $package_build
cp -rf $package_dir/debian $package_build

cp -r $build_tmp/emoncms-device $package_build/device

mkdir $package_build/scripts
cp $emonscripts_dir/common/emonmucdevupdate.php $package_build/scripts/device_update.php
