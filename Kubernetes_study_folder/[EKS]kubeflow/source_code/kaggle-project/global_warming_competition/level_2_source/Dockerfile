
#커스텀 도커파일

FROM ubuntu:22.04

# We need to run as root for updates
USER root


RUN apt-get update

RUN apt-get install -y python3
#RUN add-apt-repository universe
RUN apt-get update

RUN apt-get install -y libsm6 libxext6 libxrender-dev
RUN apt-get install -y python3-pip

RUN pip3 install minio==6.0.2
RUN pip3 install opencv-python-headless
RUN pip3 install pandas
RUN pip3 install numpy
RUN pip3 install kaggle

# Switch the user back; using jovyan as a user is bad but the base image
# depends on it.
#USER ubuntu


# Fix permissions
WORKDIR /var/source

ADD ./* /var/source/

#ENTRYPOINT ["python", "$MAIN_FILE"]
