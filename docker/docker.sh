#!/usr/bin/env bash

echo "安装 docker"

curl -fsSL get.docker.com | sh

echo

echo "设置自启动"

systemctl enable docker && systemctl start docker
