#!/usr/bin/env bash

if [[ ! -d /opt/tuic ]]; then
    echo "创建文件夹"
    mkdir -p /opt/tuic && cd /opt/tuic
else
    echo "文件夹已存在 🎉 "
    cd /opt/tuic
fi

echo "正在安装依赖..."

if typr wget certbot >/dev/null 2>&1; then
    echo "依赖已安装 🎉"
else
    echo "依赖未安装"
    if [[ -f /etc/redhat-release ]]; then
        yum install wget certbot -y
    else
        apt install wget certbot -y
    fi
fi

if type node </dev/null >/dev/null 2>&1; then
    echo "已安装nodejs 🎉"
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
    echo "已安装pm2 🎉"
else
    echo "正在安装pm2"
    npm install pm2 -g
fi

OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
    OS_ARCH="x86_64"
    echo "当前系统架构为 ${OS_ARCH}"
elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "aarch64" ]]; then
    OS_ARCH="aarch64"
    echo "当前系统架构为 ${OS_ARCH}"
else
    OS_ARCH="amd64"
    echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi

echo "正在下载tuic..."
if [[ -f /opt/tuic/tuic ]]; then
    echo "tuic已存在 🎉"
else
    echo "正在下载tuic..."
    wget https://github.com/EAimTY/tuic/releases/download/0.8.5/tuic-server-0.8.5-${OS_ARCH}-linux-gnu -O tuic && chmod +x tuic
fi

echo "申请证书..."
if [[ -f /opt/tuic/fullchain.pem ]]; then
    echo "证书已申请 🎉"
else
    echo "正在申请证书..."
    read -p "请输入域名: " DOMAIN
    read -p "请输入邮箱(默认ssl@app2022.ml): " EMAIL
    certbot certonly --standalone -d ${DOMAIN} --agree-tos --register-unsafely-without-email --email ${ EMAIL:-ssl@app2022.ml}
    cp /etc/letsencrypt/live/${DOMAIN}/*.pem /opt/tuic/
fi

echo "正在创建配置文件..."

if [[ -f /opt/tuic/tuic.conf ]]; then

    echo "配置文件已存在🎉"
else
    echo "正在创建配置文件"

    read -p "请输入密码:(默认123456) " password

    read -p "请输入端口:(默认11443)" port

    cat >/opt/tuic/tuic.conf <<EOF
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

fi
echo "正在启动tuic..."
if [[ $(pm2 ls | grep tuic | wc -l) -gt 0 ]]; then
    echo "正在重启tuic..."
    pm2 restart tuic
else
    echo "正在启动tuic...🎉"
    pm2 start ./tuic -- -c tuic.conf
fi

echo "开机自启动..."
pm2 save

echo "正在读取snell运行日志..."

pm2 log tuic --lines 10 --raw --nostream

echo "tuic 安装完成 🎉 🎉 🎉 "
