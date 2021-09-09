#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "Install Apache2"
echo "-------------------------------------------------------------"
sudo apt-get install -y apache2 gettext

sudo sed -i "s/^CustomLog/#CustomLog/" /etc/apache2/conf-available/other-vhosts-access-log.conf

# Enable apache mod rewrite
sudo a2enmod rewrite

# Default apache2 configuration
sudo cp $emonscripts_dir/defaults/apache2/emonsd.conf /etc/apache2/conf-available/emonsd.conf
sudo a2enconf emonsd.conf

# Configure virtual host
sudo cp $emonscripts_dir/defaults/apache2/emoncms.conf /etc/apache2/sites-available/emoncms.conf
sudo a2dissite 000-default.conf
sudo a2ensite emoncms

seal_id=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2 | cut -c9-16)
seal_domain="$seal_id.seal.isc-konstanz.de"
if ! grep -q $seal_domain                                    /etc/apache2/sites-available/emoncms.conf; then
    sudo sed -i "/ServerName/a\    ServerAlias $seal_domain" /etc/apache2/sites-available/emoncms.conf
fi
sudo systemctl restart apache2
