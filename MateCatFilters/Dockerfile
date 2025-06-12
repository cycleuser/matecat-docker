FROM maven:3.3.3-jdk-8

# 更换为Debian Jessie的archive源
RUN echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/10no-check-valid-until

RUN apt-get update
RUN apt-get install -y git

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
