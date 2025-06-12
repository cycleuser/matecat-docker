FROM maven:3.8-openjdk-8

# 接收构建时代理参数
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# 设置代理环境变量
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}

# 更新包列表并安装git
RUN apt-get update && \
    apt-get install -y git

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
