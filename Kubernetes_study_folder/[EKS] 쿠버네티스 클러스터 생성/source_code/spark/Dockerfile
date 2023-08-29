
#커스텀 도커파일
#only for spark pod
#spark-3.4.1-bin-hadoop3.tgz 
#wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar
#wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar
#왠지 container build하면서 spark가 다운로드가 안되서 그냥 다운로드 받은걸 copy로 붙여넣음

FROM ubuntu:20.04

# We need to run as root for updates
USER root
# Set an environment variable for where we are going to put Spark 주
ENV SPARK_HOME /opt/spark
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:${JAVA_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_PYTHON=/usr/bin/python3


# Install Java because Spark needs it
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk


# Install Spark
COPY spark /opt/spark

RUN apt-get install -y python3
#RUN add-apt-repository universe
RUN apt-get update
RUN apt-get install -y python3-pip


RUN cd /opt/spark/python && pip3 install -e .

RUN pip3 install findspark
RUN pip3 install minio==6.0.2
RUN pip3 install opencv-python
RUN pip3 install pandas
RUN pip3 install numpy

# Fix permissions
WORKDIR /opt/spark/work-dir
RUN chmod -R 777 /opt/spark/
# Switch the user back; using jovyan as a user is bad but the base image
# depends on it.
USER ubuntu
