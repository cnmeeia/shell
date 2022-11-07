#!/usr/bin/env bash

mkdir /opt/tuic && cd /opt/tuic

echo "正在安装依赖..."

if typr wget certbot >/dev/null 2>&1; then
    echo "依赖已安装"
else
    echo "依赖未安装"
    if [[ -f /etc/redhat-release ]]; then
        yum install wget certbot -y
    else
        apt install wget certbot -y
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
echo "正在下载tuic..."

wget https://github.com/EAimTY/tuic/releases/download/0.8.5/tuic-server-0.8.5-x86_64-linux-gnu -O tuic-server && chmod +x tuic-server


if [[ $(netstat -tunlp | grep 80 | wc -l) -gt 0 ]]; then
    echo "80 端口被占用，请先关闭占用 80 端口的程序"
    exit 1
fi

# 如果已经申请证书 跳过申请证书

if [[ -f /opt/tuic/fullchain.pem ]]; then
    echo "证书已存在"
else
    echo "正在申请证书"
    read -p "请输入域名:" domain
    read -p "请输入邮箱:" email
    certbot certonly --standalone -d ${domain} --agree-tos --email ${email} --non-interactive
fi

echo "正在创建配置文件..."

read -p "请输入密码:(默认123456) " password

read -p "请输入端口:默认11443" port

cat <<EOF >./tuic-server.conf
{
    "port": ${port:-11443},
    "token": ["${password:-123456}"],
    "certificate": "/opt/tuic/fullchain.pem",
    "private_key": "/opt/tuic/privkey.pem",
    "ip": "0.0.0.0",
    "congestion_controller": "bbr",
    "alpn": ["h3"]
}
EOF

echo "正在启动tuic..."

if [[ $? -eq 0 ]]; then
    echo "正在重启tuic..."
    pm2 restart tuic-server
else
    echo "正在启动tuic..."
    pm2 start ./tuic-server --name tuic -- -c tuic-server.conf
fi

echo "tuic 安装完成 🎉 🎉 🎉 "
