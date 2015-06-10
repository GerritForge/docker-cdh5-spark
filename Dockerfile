FROM centos:centos6
MAINTAINER info@landoop.com

RUN yum -y update; yum -y clean all

##### Install JDK 1.7 #####
RUN yum install -y java-1.7.0-openjdk java-1.7.0-openjdk-devel

##### Install basic linux tools #####
RUN yum install -y wget unzip dialog curl sudo lsof vim axel telnet



##### Add Cloudera CDH 5 repository #####
RUN wget http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo -O /etc/yum.repos.d/cloudera-cdh5.repo
RUN rpm --import http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera
#####



##### Install HDFS services #####
RUN yum install -y hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-hdfs-datanode

##### Install YARN services #####
RUN yum install -y hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-yarn-proxyserver

##### Install MapReduce services #####
RUN yum install -y hadoop-mapreduce hadoop-mapreduce-historyserver

##### Install Hadoop client & Hadoop conf-pseudo #####
RUN yum install -y  hadoop-client hadoop-conf-pseudo

##### Install Zookeeper #####
RUN yum install -y zookeeper zookeeper-server

##### Install HBase #####
RUN yum install -y hbase-master hbase hbase-thrift

##### Install Oozie #####
RUN yum install -y oozie oozie-client

##### Install Spark #####
RUN yum install -y spark-core spark-master spark-worker spark-history-server spark-python

##### Install Hive #####
RUN yum install -y hive hive-metastore hive-hbase

##### Install Pig #####
RUN yum install -y pig

##### Install Impala #####
RUN yum install -y impala impala-server impala-state-store impala-catalog impala-shell

##### Install Hue #####
RUN yum install -y hue hue-server

##### Install SolR #####
RUN yum -y install solr-server hue-search



##### Install MySQL and connector #####
RUN yum -y install mysql mysql-server mysql-connector-java
RUN ln -s /usr/share/java/mysql-connector-java.jar /usr/lib/hive/lib/mysql-connector-java.jar
##### Note: Will use mysql for Hive metastore



##### Format HDFS #####
USER hdfs
RUN hdfs namenode -format
USER root
#####

##### Initialize HDFS Directories #####
RUN bash -c 'for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do service $x start ; done' ; \
    bash /usr/lib/hadoop/libexec/init-hdfs.sh \
    oozie-setup sharelib create -fs hdfs://localhost -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz ; \
    bash -c 'for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do service $x stop ; done' ;
##### Note: Keep commands on a single line, as we need to init HDFS while services are running

##### Set up Oozie / HUE / Hive ??? #####
RUN oozie-setup db create -run
RUN sed -i 's/secret_key=/secret_key=_S@s+D=h;B,s$C%k#H!dMjPmEsSaJR/g' /etc/hue/conf/hue.ini



##### Install Apache Maven #####
RUN wget http://www.apache.org/dist/maven/binaries/apache-maven-3.2.2-bin.zip -O /usr/local/src/maven-3.2.2.zip
RUN unzip /usr/local/src/maven-3.2.2.zip -d /opt
RUN mv /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/bin/mvn
RUN bash -c "echo 'MAVEN_HOME=/opt/maven' > /etc/profile.d/maven.sh"
RUN bash -c "echo 'MAVEN_OPTS=\"-Xmx2g -Xmx512m -XX:MaxPermSize=512m -XX:ReservedCodeCacheSize=512m\"' >> /etc/profile.d/maven.sh"
RUN bash -c "echo 'export CLASSPATH=.' >> /etc/profile.d/maven.sh"
# Remove - RUN source /etc/profile.d/maven.sh
#####

##### Install Gradle #####
RUN mkdir /opt/gradle
RUN wget -N http://services.gradle.org/distributions/gradle-2.3-all.zip
RUN unzip -oq ./gradle-2.3-all.zip -d /opt/gradle
RUN ln -sfnv gradle-2.3 /opt/gradle/latest
RUN printf "export GRADLE_HOME=/opt/gradle/latest\nexport PATH=\$PATH:\$GRADLE_HOME/bin" > /etc/profile.d/gradle.sh
RUN ln -s /opt/gradle/latest/bin/gradle /usr/bin/gradle
#####

##### Install SBT #####
RUN curl https://bintray.com/sbt/rpm/rpm -o /etc/yum.repos.d/bintray-sbt-rpm.repo
RUN yum -y install sbt
# TODO(?) add sbt-launcher
#####

##### Make this container SSH friendly #####
RUN yum -y install openssh-server openssh-clients
# Start `sshd` to generate host DSA & RSA keys
RUN service sshd start
# Create a home folder for Jenkins
RUN useradd --user-group --system --home-dir /home/jenkins/ jenkins
# Create a jenkins `.ssh` directory with correct permissions
RUN mkdir -p /home/jenkins/.ssh/
RUN chmod 700 /home/jenkins/.ssh/
# Copy the provided public SSH key into `authorized_keys` so that Jenkins master can SSH into this container
ADD keys/jenkins_master_docker_id_rsa.pub /home/jenkins/.ssh/authorized_keys
RUN chmod 600 /home/jenkins/.ssh/authorized_keys
# Allow jenkins user to `sudo`
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN sed 's/requiretty/!requiretty/' -i /etc/sudoers
RUN echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> /home/jenkins/.ssh/config
#####

# Install Apache Kafka
# cd /opt
# wget http://www.mirrorservice.org/sites/ftp.apache.org/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz
# tar zxvf kafka_2.11-0.8.2.1.tgz
# cd kafka_2.11-0.8.2.1
#
#
#  OOOOR
#
#RUN cd /opt ; wget https://s3.amazonaws.com/publicarchive/kafka/kafka-0.8.1-1.el6.x86_64.rpm
#RUN yum install -y kafka-0.8.1-1.el6.x86_64.rpm
#RUN service kafka-server start
# Port : 9092


ADD files/hive-site.xml /usr/lib/hive/conf/


# Add the Hadoop start-up scripts
ADD scripts/* /opt/

ENV LANG en_US.UTF-8

ADD run.sh /usr/bin/

ADD ojdbc6.jar /opt/

RUN echo "spark.executor.extraClassPath=/opt/ojdbc6.jar | tee -a /etc/spark/conf/spark-defaults.conf"
RUN echo "spark.driver.extraClassPath=/opt/ojdbc6.jar | tee -a /etc/spark/conf/spark-defaults.conf"


CMD ["run.sh"]
