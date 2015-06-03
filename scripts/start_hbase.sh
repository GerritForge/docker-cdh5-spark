#!/usr/bin/env bash
. $(dirname $0)/colors.sh

green "-- Starting HBase master and thrift server --"
service hbase-master start
service hbase-thrift start