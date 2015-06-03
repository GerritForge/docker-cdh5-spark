#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Setting up mysql to act as metastore --"
sudo service mysqld start
sudo /usr/bin/mysqladmin -u root password 'pass'
mysql -u root -ppass -e "CREATE DATABASE metastore;USE metastore;SOURCE /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql;"

green "-- Starting Hive metastore --"
sudo mkdir -p /var/lib/hive
sudo chmod a+rw -R /var/lib/hive
sudo sed -i.bak "s/FULLY-QUALIFIED-DOMAIN-NAME/0.0.0.0/g" /usr/lib/hive/conf/hive-site.xml
sudo service hive-metastore start
