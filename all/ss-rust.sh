#!/usr/bin/env bash

if type docker >/dev/null 2>&1; then
    echo "docker 已经安装"
else
    echo "安装 docker"
    curl -sSL get.docker.com | sh
    echo "设置 docker 开启启动"
    systemctl enable docker && systemctl start docker
fi

if type docker-compose >/dev/null 2>&1; then
    echo "docker-compose 已经安装"
else
    echo "安装 docker-compose"
    curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

if docker images | grep ss-rust >/dev/null 2>&1; then
    echo "ss-rust 镜像已经存在"
else
    echo "拉取 ss-rust 镜像"
    docker pull teddysun/shadowsocks-rust
fi

if [ -f /etc/ss-rust/config.json ]; then
    echo "配置文件已经存在"
else
    echo "创建配置文件"
    mkdir -p /etc/ss-rust
    cat >/etc/ss-rust/config.json <<EOF
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

fi

if docker ps | grep ss-rust >/dev/null 2>&1; then
    echo "ss-rust 已经启动"
    docker restart ss-rust
else
    echo "启动 ss-rust"
    docker run -d -p 9099:9099 -p 9099:9099/udp --name ss-rust --restart=always -v /etc/shadowsocks-rust:/etc/shadowsocks-rust teddysun/shadowsocks-rust
fi

echo " 安装完成 🎉 🎉 🎉 "
