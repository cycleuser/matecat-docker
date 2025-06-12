#!/bin/bash

# 为Docker守护进程配置代理设置
sudo mkdir -p /etc/systemd/system/docker.service.d

# 创建代理配置文件
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=http://192.168.56.1:7890"
Environment="HTTPS_PROXY=http://192.168.56.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com"
EOF

# 重新加载systemd配置
sudo systemctl daemon-reload

# 重启Docker服务
sudo systemctl restart docker

# 验证配置
sudo systemctl show --property=Environment docker

echo "Docker代理配置完成！" 