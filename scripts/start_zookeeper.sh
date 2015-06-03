#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting Zookeeper --"
/etc/init.d/zookeeper-server init
/etc/init.d/zookeeper-server start