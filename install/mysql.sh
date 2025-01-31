#!/bin/bash
source load_config.sh

echo "-------------------------------------------------------------"
echo "Install Mariadb Server and Client (MySQL)"
echo "-------------------------------------------------------------"
sudo apt-get install -y mariadb-server mariadb-client

# Secure mysql
echo "- Secure MYSQL"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;"
# Create the emoncms database using utf8 character decoding:
echo "- Create $mysql_database database"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $mysql_database DEFAULT CHARACTER SET utf8;"
# Add emoncms database, set user permissions
echo "- Add user:$mysql_user and assign to database:$mysql_database"
sudo mysql -e "CREATE USER IF NOT EXISTS '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_password';"
sudo mysql -e "GRANT ALL ON $mysql_database.* TO '$mysql_user'@'localhost';FLUSH PRIVILEGES;"

if [ -z "$mysql_timeseries" ]; then
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS $mysql_timeseries DEFAULT CHARACTER SET utf8;"
    sudo mysql -e "GRANT ALL ON $mysql_timeseries.* TO '$mysql_user'@'localhost';FLUSH PRIVILEGES;"
fi
