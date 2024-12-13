#!/usr/bin/env bash
echo
apt update && apt install wget curl unzip jq -y
echo
echo "安装 docker"

curl -fsSL get.docker.com | sh

echo

echo "设置自启动"

systemctl enable docker && systemctl start docker

echo 

echo "安装 docker-compose"

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose  && chmod +x /usr/local/bin/docker-compose  && docker-compose --version

