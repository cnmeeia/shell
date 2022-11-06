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

echo "正在下载tuic..."

wget -P /opt/tuic/  https://github.com/EAimTY/tuic/releases/download/0.8.5/tuic-server-0.8.5-x86_64-linux-gnu

echo "正在授权tuic..."

chmod +x /opt/tuic/tuic-server-0.8.5-x86_64-linux-gnu

if [[ $(netstat -tunlp | grep 80 | wc -l) -gt 0 ]]; then
    echo "80 端口被占用，请先关闭占用 80 端口的程序"
    exit 1
fi

read -p "请输入域名:" domain

read -p "请输入邮箱:" email

echo "正在申请证书..."

certbot certonly \
--standalone \
--agree-tos \
--no-eff-email \
--email $email \
-d $domain

echo "正在配置证书..."

cp /etc/letsencrypt/live/$domain/fullchain.pem .

cp /etc/letsencrypt/live/$domain/privkey.pem .


read -p "请输入密码:" password

read -p "请输入端口:" port

echo "正在创建配置文件..."

cat << EOF > ./tuic-server.conf
{
    "port": $port,
    "token": ["$password"],
    "certificate": "/opt/tuic/fullchain.pem",
    "private_key": "/opt/tuic/privkey.pem",
    "ip": "0.0.0.0",
    "congestion_controller": "bbr",
    "alpn": ["h3"]
}
EOF

echo "正在设置启动tuic..."

cat << EOF > /etc/systemd/system/tuic.service
[Unit]
Description=Delicately-TUICed high-performance proxy built on top of the QUIC protocol
Documentation=https://github.com/EAimTY/tuic
After=network.target

[Service]
User=root
WorkingDirectory=/opt/tuic
ExecStart=/opt/tuic/tuic-server-0.8.5-x86_64-linux-gnu -c config.json
Restart=on-failure
RestartPreventExitStatus=1
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "正在启动tuic..."

systemctl daemon-reload && systemctl enable tuic && systemctl start tuic && systemctl status tuic


echo "tuic安装完成"

echo "tuic配置文件路径：/opt/tuic/tuic-server.conf"

echo "tuic日志路径：/var/log/tuic.log"

echo "tuic启动命令：systemctl start tuic"


