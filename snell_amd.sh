#!/usr/bin/env bash

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

echo "正在下载snell..."
wget https://dl.nssurge.com/snell/snell-server-v4.0.0-linux-amd64.zip

echo "正在解压snell..."
rm -rf snell-server && unzip snell-server-v4.0.0-linux-amd64.zip

echo "正在创建配置文件..."
cat << EOF > ./snell-server.conf
[snell-server]
listen = 0.0.0.0:33670
psk = DsU0x9afoOKLoWI1kUYnlxj6tv3YDef
ipv6 = false
obfs = http
EOF

echo "正在创建服务..."
pm2 start ./snell-server -n snell

echo "正在启动服务..."
pm2 start snell && pm2 save && pm2 ls

echo "安装完成！"

echo "配置文件路径：/root/snell-server.conf"

echo "服务管理命令：pm2 start snell"

echo "服务停止命令：pm2 stop snell"

echo "服务重启命令：pm2 restart snell"

echo "服务删除命令：pm2 delete snell"
