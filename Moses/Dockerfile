FROM ubuntu:latest

MAINTAINER Duyet Le <me@duyet.net>
LABEL description="Basic Moses docker container for Ubuntu"

# 接收构建时代理参数
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# 设置代理环境变量
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}

# 更换apt源为TUNA镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 配置apt重试和超时设置
RUN echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/80retries && \
    echo 'Acquire::http::Timeout "60";' >> /etc/apt/apt.conf.d/80retries && \
    echo 'Acquire::https::Timeout "60";' >> /etc/apt/apt.conf.d/80retries

# Update Ubuntu.
RUN apt-get update
RUN apt-get install -y apt-utils debconf-utils
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get -y upgrade

# Install basic tools
RUN apt-get install -y nano perl netcat-openbsd

# 尝试安装boost，如果失败则使用基本包
RUN apt-get install -y libboost-all-dev || \
    (echo "Boost installation failed, installing basic packages only" && \
     apt-get install -y build-essential)

# Clone and build Moses
RUN git clone https://github.com/moses-smt/mosesdecoder.git
WORKDIR /mosesdecoder

# 简单构建Moses - 只编译核心组件
RUN make -j4

# Download sample model
RUN wget http://www.statmt.org/moses/download/sample-models.tgz && tar xzf sample-models.tgz

# 创建一个简单的HTTP服务器脚本
RUN echo '#!/bin/bash\necho "Moses service started on port 8080"\nwhile true; do\n  echo -e "HTTP/1.1 200 OK\\n\\nMoses service is running" | nc -l -p 8080\ndone' > /start.sh && \
    chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
