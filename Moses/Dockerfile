FROM ubuntu:latest

MAINTAINER Duyet Le <me@duyet.net>
LABEL description="Basic Moses docker container for Ubuntu"

# 更换apt源为TUNA镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# Update Ubuntu.
RUN apt-get update
RUN apt-get install -y apt-utils debconf-utils
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get -y upgrade

# Install some necessary tools.
RUN apt-get install -y nano perl

# Install Moses dependencies.
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y build-essential git-core pkg-config automake libtool wget zlib1g-dev python3-dev python-dev-is-python3 libbz2-dev cmake

# Clone and build Moses
RUN git clone https://github.com/moses-smt/mosesdecoder.git
WORKDIR /mosesdecoder

# 创建build目录并使用cmake构建
RUN mkdir build && cd build && \
    cmake .. && \
    make -j4

# Download sample model
RUN wget http://www.statmt.org/moses/download/sample-models.tgz && tar xzf sample-models.tgz

EXPOSE 8080

WORKDIR /mosesdecoder/sample-models
ENTRYPOINT [ "/mosesdecoder/bin/mosesserver", "-f", "phrase-model/moses.ini" ]
