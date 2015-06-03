#!/bin/bash
#
# Check-1 - Is HDFS working
# Check-2 - Is MapReduce working
# Check-3 - Is HBase working
# Check-4 - Is Hive working
# Check-5 - Is Impala working
# Check-6 - Is Spark working

if [[ -z "$1" ]];
then
        user=$(whoami)
else
        user=$1
fi

function red() { echo -e "\e[1;31m$1\e[0m"; }
function green() { echo -e "\e[1;32m$1\e[0m"; }

# Helper function
processExitCode () {
  # Expect 2 parameters
  if [ -z "$2" ]
  then
    red "[Failed] Expected number of parameters is 2"
    return 250
  fi

  result=$1
  message=$2

  if [ "$result" == "0" ]; then
     green "[Success] $2";
  else
     red "[Failed] $2";

  fi
}

if [ "$(whoami)" == "smokeTest" ]; then
  echo " $ sudo adduser smokeTest"
  echo " $ sudo -u hdfs hadoop fs -mkdir -p /user/smokeTest; sudo -u hdfs hadoop fs -chown -R smokeTest /user/smokeTest"
  echo " $ sudo -u smokeTest ./post-installation.sh";

fi

echo ""
echo "###############################################################################################################################"
echo ""
echo "Running Smoke tests to verify all the Hadoop components"
echo ""
echo "###############################################################################################################################"
echo ""
echo "Check-1: Is HDFS working for ${user}?" ; sleep 2
echo ""
mkdir -p /tmp/${user}
rm -r -f /tmp/${user}/test.txt
echo "this is a test" > /tmp/${user}/test.txt
hadoop fs -mkdir -p /user/${user}/test
hadoop fs -ls /user/${user}
hadoop fs -put -f /tmp/${user}/test.txt /user/${user}/test/
hadoop fs -ls /user/${user}/test
hadoopcat=$(hadoop fs -cat /user/${user}/test/test.txt)
if [[ "$hadoopcat" = "this is a test" ]]
then
  green "[Success] HDFS test"
else
  red "[Failed] HDFS test"

fi
hadoop fs -rm -skipTrash /user/${user}/test/test.txt
hadoop fs -rmdir /user/${user}/test

echo ""
echo "###############################################################################################################################"
echo ""
echo "Check-2: Is Map-Reduce working ? " ; sleep 2
echo ""
mapreduce=$(hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-examples-*.jar pi 1 1 | grep "Estimated value of Pi is 4.00000000000000000000")
if [[ "$mapreduce" = "Estimated value of Pi is 4.00000000000000000000" ]]
then
  green "[Success] MapReduce test"
else
  red "[Failed] MapReduce test"

fi

echo ""
echo "##############################################################################################################################"
echo ""
echo "Check-3 Is HBase working ? " ; sleep 2
echo ""
user=$(whoami)

namespace=${user/./_}

echo "Dropping table if exists"
echo "disable '${namespace}:${user}_test'" | hbase shell -n
echo "drop '${namespace}:${user}_test'" | hbase shell -n

echo "create_namespace '${namespace}'" | hbase shell -n
echo "create '${namespace}:${user}_test', 'cf'" | hbase shell -n
processExitCode $? "HBase 'create' table"

echo "put '${namespace}:${user}_test', 'row1', 'cf:a', 'value1'" | hbase shell -n
processExitCode $? "HBase 'put' table"

echo "get '${namespace}:${user}_test', 'row1'" | hbase shell -n
processExitCode $? "HBase 'get' table"

echo "disable '${namespace}:${user}_test'" | hbase shell -n
echo "drop '${namespace}:${user}_test'" | hbase shell -n

echo ""
echo "#################################################################################################################################"
echo ""
echo "Check-4 Is Hive working ? " ; sleep 2
echo ""

user=$(whoami)

namespace=${user/./_}

rm -rf /var/lib/hive/metastore/metastore_db/db*.lck

mkdir -p /tmp/${namespace}
echo "1,2" > /tmp/${namespace}/hivedata.csv;
echo "3,4" >> /tmp/${namespace}/hivedata.csv
cmd="CREATE DATABASE IF NOT EXISTS ${namespace}; USE ${namespace}; CREATE TABLE IF NOT EXISTS testing (a STRING, b STRING) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' STORED AS TEXTFILE;load data LOCAL INPATH '/tmp/${namespace}/hivedata.csv' INTO TABLE testing; select a, b from testing;"
echo ${cmd}
hive -e "${cmd}" | head -n 6
processExitCode ${PIPESTATUS[0]} "Hive table creation and population"

echo "#################################################################################################################################"
echo ""
echo "Check-5 Is Impala working ? " ; sleep 2
echo ""

user=$(whoami)

namespace=${user/./_}

impalarefresh=$(impala-shell -q 'invalidate metadata')
impalarecreatedb=$(impala-shell -q 'create database IF NOT EXISTS root')
impalacreate=$(impala-shell -d root -q "CREATE TABLE IF NOT EXISTS impala_test (a STRING, b STRING) STORED AS PARQUETFILE;")
processExitCode $? "Impala 'create' table "
impalainsert=$(impala-shell -d root -q "INSERT INTO impala_test (a,b) VALUES('hello','impala');")
processExitCode $? "Impala 'insert' "
impala-shell -d root -q 'SELECT a, b FROM impala_test;'
impaladrop=$(impala-shell -d root -q "DROP TABLE impala_test;")
processExitCode $? "Impala 'drop' "

hive --database "root" -e "DROP TABLE testing" | head -n 3
processExitCode $? "Drop 'testing' table"

echo "#################################################################################################################################"
echo ""
echo "Check- Is Spark working ? " ; sleep 2
echo ""
export "HADOOP_CONF_DIR=/etc/hadoop/conf"
TMPFILE=`mktemp /tmp/tmp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
echo "Running Spark job"

spark-submit --class org.apache.spark.examples.SparkPi --master yarn-cluster --executor-memory 1G --num-executors 10  /usr/lib/spark/lib/spark-examples-*.jar 100 --driver-class-path /usr/lib/spark/lib/slf4j-log4j12-1.7.5.jar &> $TMPFILE
processExitCode ${PIPESTATUS[0]} "Spark execution "
head -n 12 $TMPFILE

echo "#################################################################################################################################"