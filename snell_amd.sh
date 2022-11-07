#!/usr/bin/env bash

mkdir -p /root/snell

echo "正在安装依赖..."

if type wget unzip >/dev/null 2>&1; then
    echo "依赖已安装"
else
    echo "依赖未安装"
    if [[ -f /etc/redhat-release ]]; then
        yum install wget unzip -y
    else
        apt install wget unzip -y
    fi
fi

if type node </dev/null >/dev/null 2>&1; then
    echo "已安装nodejs"
else
    echo "正在安装nodejs"
    if type apt >/dev/null 2>&1; then
        curl -sL https://deb.nodesource.com/setup_16.x | bash -
        apt install -y nodejs
    elif type yum >/dev/null 2>&1; then
        curl -sL https://rpm.nodesource.com/setup_16.x | bash -
        yum install -y nodejs
    else
        echo "不支持的操作系统！"
        exit 1
    fi
fi

if type pm2 </dev/null >/dev/null 2>&1; then
    echo "已安装pm2"
else
    echo "正在安装pm2"
    npm install pm2 -g
fi

cd /root/snell/

echo "正在下载snell..."
wget https://dl.nssurge.com/snell/snell-server-v4.0.0-linux-amd64.zip

echo "正在解压snell..."
rm -rf snell-server && unzip snell-server-v4.0.0-linux-amd64.zip && rm -f snell-server-v4.0.0-linux-amd64.zip

read -p "请输入snell服务端口(默认11443):" port

echo "正在创建配置文件..."
cat <<EOF >./snell-server.conf
[snell-server]
listen = 0.0.0.0:${port:-11443}
psk = DsU0x9afoOKLoWI1kUYnlxj6tv3YDef
ipv6 = false
obfs = http
EOF

# 如果有snell 运行则重启
if [[ $(pm2 list | grep snell | wc -l) -gt 0 ]]; then
    pm2 restart snell
else
    pm2 start ./snell-server -n snell -- -c ./snell-server.conf
fi

echo "snell安装完成 🎉 🎉 🎉"
