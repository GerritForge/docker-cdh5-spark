#!/usr/bin/env bash

bash -x /opt/start_HDFS.sh
bash -x /opt/prepare_HDFS.sh
bash -x /opt/start_yarn.sh
bash -x /opt/start_hive_metastore.sh
bash -x /opt/start_oozie.sh
bash -x /opt/start_zookeeper.sh
bash -x /opt/start_hbase.sh
bash -x /opt/start_spark.sh
bash -x /opt/start_impala.sh
bash -x /opt/start_spark.sh

export TERM=xterm
echo "CDH STARTED"
sleep infinity
#tail -f /var/log/messages
