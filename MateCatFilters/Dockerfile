FROM maven:3.3.3-jdk-8

# 更换apt源为TUNA镜像源
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y git

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
