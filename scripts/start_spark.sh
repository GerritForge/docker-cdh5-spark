#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting Spark --"
service spark-master start
service spark-worker start