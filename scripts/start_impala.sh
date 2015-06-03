#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting impala daemons --"
bash -c 'for x in `cd /etc/init.d ; ls impala-*` ; do sudo service $x start ; done'