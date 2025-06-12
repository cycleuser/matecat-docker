#!/bin/bash

echo "=== MateCat Docker Ubuntu 24.04 部署脚本 ==="

# 设置代理环境变量
export HTTP_PROXY=http://192.168.56.1:7890
export HTTPS_PROXY=http://192.168.56.1:7890
export NO_PROXY=localhost,127.0.0.1

echo "1. 配置Docker守护进程代理..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://192.168.56.1:7890"
Environment="HTTPS_PROXY=http://192.168.56.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

echo "2. 重启Docker服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "3. 配置Docker客户端代理..."
mkdir -p ~/.docker
cat > ~/.docker/config.json << EOF
{
  "proxies": {
    "default": {
      "httpProxy": "http://192.168.56.1:7890",
      "httpsProxy": "http://192.168.56.1:7890",
      "noProxy": "localhost,127.0.0.1"
    }
  }
}
EOF

echo "4. 启动MateCat服务..."
docker-compose up --build

echo "=== 部署完成 ===" 