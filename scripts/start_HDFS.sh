#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting HDFS services --"
bash -c 'for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done'
sleep 5