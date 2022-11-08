
echo "安装 docker"

curl -sSL get.docker.com | sh

echo "设置 docker 开启启动"

systemctl enable docker && systemctl start docker

echo "安装 ss-rust"

docker pull shadowsocks/shadowsocks-rust

echo "创建配置文件"

mkdir -p /etc/shadowsocks-rust

cat > /etc/shadowsocks-rust/config.json << EOF
{
    "server":"0.0.0.0",
    "server_port":9099,
    "password":"125390",
    "timeout":300,
    "method":"aes-128-gcm",
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp"
}
EOF

echo "创建 docker 容器"

docker run -d --name ss-rust --restart=always -p 9099:9099 -v /etc/shadowsocks-rust:/etc/shadowsocks-rust shadowsocks/shadowsocks-rust

echo "安装完成"

echo "配置文件路径：/etc/shadowsocks-rust/config.json"

