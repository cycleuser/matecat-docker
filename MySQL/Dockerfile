FROM ostico/trusty-base:latest

# 接收构建时代理参数
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# 设置代理环境变量
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV NO_PROXY=${NO_PROXY}

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -snvf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# 如果有代理，配置apt使用代理
RUN if [ -n "$HTTP_PROXY" ]; then \
        echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >> /etc/apt/apt.conf.d/01proxy; \
        echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/01proxy; \
    fi

# 更新包列表并安装MySQL（使用Ubuntu默认源）
RUN apt-get update && \
    echo "mysql-server mysql-server/root_password password admin" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password admin" | debconf-set-selections && \
    apt-get install -y mysql-server mysql-client

COPY run.sh /tmp/run.sh
RUN chmod +x /tmp/run.sh

COPY my.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf
RUN chmod 660 /etc/mysql/my.cnf

ENV MYSQL_PASS "admin"
COPY create_mysql_admin_user.sh /tmp/create_mysql_admin_user.sh
RUN chmod +x /tmp/create_mysql_admin_user.sh

CMD ["/tmp/run.sh"]

