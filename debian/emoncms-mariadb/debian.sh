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

sed -i 's~<root_dir>~'$emoncms_www'~g' $package_build/debian/postinst
