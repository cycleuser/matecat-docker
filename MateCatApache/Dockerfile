FROM ubuntu:20.04

# 接收构建时代理参数
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# 设置代理环境变量
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}

# Prepare the environment
ENV PHP_POST_MAX_SIZE 1024M
ENV PHP_UPLOAD_MAX_FILESIZE 1024M
ENV PHP_MAX_MEMORY 4096M
ENV DEBIAN_FRONTEND noninteractive

ENV SERVICES_DIR "/etc/init.d"
ENV USER_OWNER "www-data"
ENV MATECAT_HOME "/var/www/matecat"

# 更换apt源为TUNA镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 基础系统更新和工具安装
RUN apt-get update && \
    apt-get -y --fix-missing install ssh-client vim locate iputils-ping monit git curl wget net-tools \
    apache2 apache2-dev libapache2-mod-php \
    php php-xdebug php-json php-xml php-curl php-mysql php-mbstring php-dev php-redis php-zip php-gd mysql-client libzip-dev \
    certbot python3-certbot-apache redis-tools nodejs npm \
    openssh-server psmisc screen dstat traceroute whois libaio1 perl perl-base perl-modules \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get -y upgrade

# 配置npm使用淘宝镜像
RUN npm config set registry https://registry.npmmirror.com

COPY ./app_configs/config.ini /tmp/config.ini
COPY ./app_configs/node_config.ini /tmp/node_config.ini
COPY ./app_configs/Error_Mail_List.ini /tmp/Error_Mail_List.ini

# If you want to enable the login ssystem add your oauth_config.ini taken from Google
#COPY ./app_configs/oauth_config.ini /tmp/oauth_config.ini

COPY ./app_configs/task_manager_config.ini /tmp/task_manager_config.ini

# Monit
COPY monitrc /etc/monit/monitrc

# Apache
RUN mkdir -p /var/log/apache2/matecat/
RUN rm -rf /etc/apache2/sites-available/default
RUN rm -rf /etc/apache2/sites-enabled/*
RUN userdel www-data
RUN groupadd www-data
RUN useradd -ms /bin/bash -g www-data www-data

## ENABLE Deployment utils ( apache follows symbolic links to DocumentRoot )
RUN git clone https://github.com/etsy/mod_realdoc.git
WORKDIR "/mod_realdoc"
RUN apxs2 -i -a -c mod_realdoc.c
WORKDIR "/"
RUN rm -rf ./mod_realdoc

## Enable MateCat site
COPY 000-matecat.conf /etc/apache2/sites-enabled/000-matecat.conf
RUN a2enmod rewrite filter deflate headers expires proxy_http

# SSH Server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Start application
COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

WORKDIR "/var/www/matecat"
CMD ["/tmp/run.sh"]
