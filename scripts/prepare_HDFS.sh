#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Preparing HDFS directories --"
hadoop fs -ls /
hadoop fs -ls /user
sudo -n -u hdfs /usr/bin/hadoop fs -chmod -R a+w /
sudo -n -u hdfs /usr/bin/hadoop fs -mkdir -p /user/hadoop /user/hive/warehouse /hbase /tmp /var
sudo -n -u hdfs /usr/bin/hadoop fs -chmod -R a+w /user
sudo -n -u hdfs /usr/bin/hadoop fs -chown hadoop /user/hadoop
sudo -n -u hdfs /usr/bin/hadoop fs -chown hbase /hbase
sudo -n -u hdfs /usr/bin/hadoop fs -chmod a+w /hbase
sudo -n -u hdfs /usr/bin/hadoop fs -chmod -R 777 /tmp
sudo -n -u hdfs /usr/bin/hadoop fs -chmod -R 777 /var
sudo -n -u hdfs hadoop fs -chown oozie:oozie /user/oozie
