#!/bin/bash
#Description: Build script to generate the emoncms debian package
package_vers=$version
package_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
package_name="$(basename "$package_path")"
package_id="$package_name"-"$package_vers"
package_build="$build_dir/$package_id"

mkdir -p $package_build

cp -r $defaults_dir/debian $package_build
cp -rf $package_dir/debian $package_build

mkdir $package_build/conf-available $package_build/sites-available
cp $defaults_dir/apache2/emoncms.conf $package_build/sites-available/emoncms.conf
cp $defaults_dir/apache2/emonsd.conf $package_build/conf-available/emoncms.conf
