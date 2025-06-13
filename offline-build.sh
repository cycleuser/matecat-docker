#!/bin/bash

echo "==== MateCat 离线构建脚本 ===="

# 创建基本目录结构
echo "1. 创建基本目录结构..."
mkdir -p offline/filters
mkdir -p offline/mysql
mkdir -p offline/matecat
mkdir -p offline/redis
mkdir -p offline/amq
mkdir -p offline/moses

# 创建基本Dockerfile
echo "2. 创建基本Dockerfile..."

# 创建Redis Dockerfile
cat > offline/redis/Dockerfile << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y redis-server
EXPOSE 6379
CMD ["redis-server", "--protected-mode", "no"]
EOF

# 创建AMQ Dockerfile
cat > offline/amq/Dockerfile << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y wget openjdk-8-jdk
RUN wget https://archive.apache.org/dist/activemq/5.13.2/apache-activemq-5.13.2-bin.tar.gz -O /tmp/activemq.tar.gz && \
    tar -xzf /tmp/activemq.tar.gz -C /opt && \
    rm /tmp/activemq.tar.gz && \
    ln -s /opt/apache-activemq-5.13.2 /opt/activemq
EXPOSE 61613 61616 8161
CMD ["/opt/activemq/bin/activemq", "console"]
EOF

# 创建MySQL Dockerfile
cat > offline/mysql/Dockerfile << 'EOF'
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    echo "mysql-server mysql-server/root_password password admin" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password admin" | debconf-set-selections && \
    apt-get install -y mysql-server
COPY ../../MySQL/run.sh /tmp/run.sh
COPY ../../MySQL/my.cnf /etc/mysql/my.cnf
COPY ../../MySQL/create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/run.sh /tmp/create_mysql_admin_user.sh
ENV MYSQL_PASS "admin"
EXPOSE 3306
CMD ["/tmp/run.sh"]
EOF

# 创建Filters Dockerfile
cat > offline/filters/Dockerfile << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y openjdk-8-jdk maven git
COPY ../../MateCatFilters/startFilter.sh /tmp/startFilter.sh
RUN chmod +x /tmp/startFilter.sh
EXPOSE 8732
CMD ["/tmp/startFilter.sh"]
EOF

# 创建Moses Dockerfile
cat > offline/moses/Dockerfile << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y netcat-openbsd
RUN echo '#!/bin/bash\necho "Moses service started on port 8080"\nwhile true; do\n  echo -e "HTTP/1.1 200 OK\\n\\nMoses service is running" | nc -l -p 8080\ndone' > /start.sh && \
    chmod +x /start.sh
EXPOSE 8080
CMD ["/start.sh"]
EOF

# 创建MateCat Dockerfile
cat > offline/matecat/Dockerfile << 'EOF'
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y --fix-missing install ssh-client vim locate iputils-ping monit git curl wget net-tools \
    apache2 apache2-dev libapache2-mod-php \
    php php-xdebug php-json php-xml php-curl php-mysql php-mbstring php-dev php-redis php-zip php-gd mysql-client libzip-dev \
    openssh-server psmisc screen dstat traceroute whois libaio1 perl perl-base perl-modules \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY ../../MateCatApache/app_configs/config.ini /tmp/config.ini
COPY ../../MateCatApache/app_configs/node_config.ini /tmp/node_config.ini
COPY ../../MateCatApache/app_configs/Error_Mail_List.ini /tmp/Error_Mail_List.ini
COPY ../../MateCatApache/app_configs/task_manager_config.ini /tmp/task_manager_config.ini
COPY ../../MateCatApache/monitrc /etc/monit/monitrc
COPY ../../MateCatApache/000-matecat.conf /etc/apache2/sites-enabled/000-matecat.conf
COPY ../../MateCatApache/run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh
RUN mkdir -p /var/log/apache2/matecat/ && \
    rm -rf /etc/apache2/sites-available/default && \
    rm -rf /etc/apache2/sites-enabled/* && \
    a2enmod rewrite filter deflate headers expires proxy_http
WORKDIR "/var/www/matecat"
CMD ["/tmp/run.sh"]
EOF

# 创建docker-compose.yml
cat > offline/docker-compose.yml << 'EOF'
version: '2'

networks:
  matecat-network:
    driver: bridge

services:
  filters:
    build: ./filters/
    container_name: docker_matecat_filter
    expose:
      - 8732
    networks:
       - matecat-network

  redis:
    build: ./redis/
    expose:
      - 6379
    networks:
       - matecat-network

  amq:
    build: ./amq/
    expose:
      - 61613
      - 61616
      - 8161
    networks:
       - matecat-network
       
  mysql:
    build: ./mysql/
    container_name: docker_mysql
    expose:
     - 3306
    networks:
       - matecat-network

  mosesdecoder:
    build: ./moses/
    expose:
     - 8080
    networks:
     - matecat-network

  matecat:
    build: ./matecat/
    container_name: docker_matecat
    volumes:
      - ~/matecat:/var/www/matecat:rw
    ports:
      - 80:80
    networks:
       - matecat-network
    links:
      - mysql
      - redis
      - amq
      - filters
      - mosesdecoder
EOF

echo "3. 复制必要文件..."
cp -r MySQL/run.sh MySQL/my.cnf MySQL/create_mysql_admin_user.sh offline/mysql/
cp -r MateCatFilters/startFilter.sh offline/filters/
cp -r MateCatApache/app_configs offline/matecat/
cp -r MateCatApache/monitrc MateCatApache/000-matecat.conf MateCatApache/run.sh offline/matecat/

echo "4. 构建离线镜像..."
cd offline
docker-compose up --build

echo "==== 离线构建完成 ====" 