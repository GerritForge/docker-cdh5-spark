#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting Yarn, M-R --"
sudo service hadoop-yarn-resourcemanager start
sudo service hadoop-yarn-nodemanager start
sudo service hadoop-mapreduce-historyserver start
# After starting mapreduce-historyserver we need to chmod
sudo -n -u hdfs /usr/bin/hadoop fs -chmod -R 777 /tmp