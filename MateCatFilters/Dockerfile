FROM maven:3.3.3-jdk-8

# 清理并设置Debian Jessie的archive源
RUN rm -f /etc/apt/sources.list.d/* && \
    echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/10no-check-valid-until && \
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/10no-check-valid-until

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y --force-yes git

COPY startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
CMD ["/tmp/startFilter.sh"]
