FROM openjdk:8
MAINTAINER delijati@gmx.net

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PYSPARK_PYTHON python3
ENV PYSPARK_DRIVER_PYTHON python3

ARG MAVEN_URL=http://central.maven.org/maven2
ARG APACHE_URL=http://archive.apache.org/dist
ARG AWS_SDK_JAVA_VERSION=1.11.467
ARG HADOOP_VERSION=2.9.2
ARG SNAPPY_VERSION=1.1.7.2
ARG JODA_TIME_VERSION=2.10.1
ARG SPARK_VERSION=2.3.2

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    apt-get install -y libsnappy-dev libssl1.0-dev && \
    apt-get install -y wget python3-pip

RUN apt-get autoclean -y
RUN apt-get autoremove -y

WORKDIR /app

# get spark and hadoop
RUN wget $APACHE_URL/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
    wget $APACHE_URL/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar xzf spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
    rm -rf spark-$SPARK_VERSION-bin-without-hadoop.tgz && \
    tar xzf hadoop-$HADOOP_VERSION.tar.gz && \
    rm -rf hadoop-$HADOOP_VERSION.tar.gz

ENV SPARK_HOME /app/spark-$SPARK_VERSION-bin-without-hadoop
ENV HADOOP_HOME /app/hadoop-$HADOOP_VERSION

# get aws server jars and other helper jars
RUN cd $SPARK_HOME/jars && \
    wget $MAVEN_URL/com/amazonaws/aws-java-sdk-core/$AWS_SDK_JAVA_VERSION/aws-java-sdk-core-$AWS_SDK_JAVA_VERSION.jar && \
    wget $MAVEN_URL/com/amazonaws/aws-java-sdk-s3/$AWS_SDK_JAVA_VERSION/aws-java-sdk-s3-$AWS_SDK_JAVA_VERSION.jar && \
    wget $MAVEN_URL/com/amazonaws/aws-java-sdk-kms/$AWS_SDK_JAVA_VERSION/aws-java-sdk-kms-$AWS_SDK_JAVA_VERSION.jar && \
    wget $MAVEN_URL/org/apache/hadoop/hadoop-aws/$HADOOP_VERSION/hadoop-aws-$HADOOP_VERSION.jar && \
    wget $MAVEN_URL/org/xerial/snappy/snappy-java/$SNAPPY_VERSION/snappy-java-$SNAPPY_VERSION.jar && \
    wget $MAVEN_URL/joda-time/joda-time/$JODA_TIME_VERSION/joda-time-$JODA_TIME_VERSION.jar

# set hadoop in spark
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh && \
    echo "export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop" >> $SPARK_HOME/conf/spark-env.sh && \
    echo "export SPARK_DIST_CLASSPATH=`${HADOOP_HOME}/bin/hadoop classpath`" >> $SPARK_HOME/conf/spark-env.sh

# install pyspark
RUN cd $SPARK_HOME/python && \
    pip3 install -e .

# check libs are there for hadoop prevent exit 1 just for info
RUN echo `hadoop-2.9.2/bin/hadoop checknative -a`

CMD bash
