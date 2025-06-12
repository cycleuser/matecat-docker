#!/bin/bash

# 创建Docker客户端配置目录
mkdir -p ~/.docker

# 创建客户端代理配置
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

echo "Docker客户端代理配置完成！" 