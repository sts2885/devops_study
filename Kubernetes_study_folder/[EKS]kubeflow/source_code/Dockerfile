
#커스텀 도커파일
#pull 받기 전에 docker ecr public 용 login하고 할것
#https://yoo11052.tistory.com/146


#https://gallery.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter-tensorflow-full
#https://www.kubeflow.org/docs/components/notebooks/container-images/

#kfp.dsl의 graph component가 안되고 따로 pip install 로 설치해도 안되서
#그냥 full로 한번 설치해보겠음

FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter-tensorflow-full:master
ARG sparkversion=3.4.1
ARG sparkrelease=spark-3.4.1-bin-without-hadoop
#ARG sparkserver https://archive.apache.org/dist/spark/spark-3.4.1/spark-3.4.1-bin-without-hadoop.tgz
ARG sparkserver=https://archive.apache.org/dist/spark

# We need to run as root for updates
USER root
# Set an environment variable for where we are going to put Spark 주
ENV SPARK_HOME /opt/spark
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:${JAVA_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_PYTHON=/usr/bin/python3
 

# Install Java because Spark needs it
#RUN apt-get update && \
# apt-get install -yq openjdk-8-jre openjdk-8-jre-headless && \
# apt-get clean && \
# rm -rf /var/lib/apt/lists/*

#진짜 쓸모없는것만 바글바글하게 깔고 실제 돌리면 하나도 안돌아가네

#https://hyem207.tistory.com/44

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk


# Install Spark
#RUN set -ex && \
# rm /bin/sh && \
# ln -sv /bin/bash /bin/sh
RUN echo "Setting up spark"
#RUN cd /tmp && \
# (wget ${sparkserver}/spark-${sparkversion}/${sparkrelease}.tgz) && \
# cd /opt && tar -xvf /tmp/${sparkrelease}.tgz && \
# rm /tmp/${sparkrelease}.tgz && mv ${sparkrelease} spark && \
# cd spark/python && pip install -e .

#spark-3.4.1-bin-hadoop3.tgz 
#wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar
#wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar
COPY spark /opt/spark

RUN cd /opt/spark/python && pip install -e .

RUN pip install findspark

#https://yahwang.github.io/posts/84
# hadoop-aws 3.2.0
#RUN wget -o /opt/spark/jars/hadoop-aws-3.2.0.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar
# aws-java-sdk 1.11.375 (compile dependency with hadoop aws)
#RUN wget -o /opt/spark/jars/aws-java-sdk-bundle-1.11.375.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.375/aws-java-sdk-bundle-1.11.375.jar

#RUN curl https://gist.githubusercontent.com/danking/f8387f5681b03edc5babdf36e14140bc/raw/23d43a2cc673d80adcc8f2a1daee6ab252d6f667/install-s3-connector.sh | bash

# Fix permissions
WORKDIR /opt/spark/work-dir
RUN chmod -R 777 /opt/spark/
# Switch the user back; using jovyan as a user is bad but the base image
# depends on it.
USER jovyan

#root 유저 상태에서 하면 jovyan에는 적용안되어 있음.

#ENV PYSPARK_SUBMIT_ARGS="--master local[2] pyspark-shell"

