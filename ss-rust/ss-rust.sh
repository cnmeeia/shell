#!/usr/bin/env bash
if type jq >/dev/null 2>&1; then
    echo
    echo "jq 已经安装 🎉"
else
    echo
    echo " 安装 jq "
    apt install jq -y >/dev/null 2>&1 || yum install jq -y >/dev/null 2>&1
fi
echo
if type docker >/dev/null 2>&1; then
    echo "docker 已经安装 🎉 "
    echo
else
    echo "安装 docker"
    curl -sSL get.docker.com | sh >/dev/null 2>&1
    echo "设置 docker 开启启动"
    systemctl enable docker && systemctl start docker
fi
echo
if type docker-compose >/dev/null 2>&1; then
    echo "docker-compose 已经安装 🎉 "
    echo
else
    echo "安装 docker-compose"
    curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi
echo
if docker images | grep shadowsocks-rust >/dev/null 2>&1; then
    echo "shadowsocks-rust 镜像已经存在 🎉 "
    echo
else
    echo "拉取 shadowsocks-rust 镜像"
    docker pull teddysun/shadowsocks-rust
fi
echo
if [ -f /etc/shadowsocks-rust/config.json ]; then
    echo "配置文件已经存在 🎉 "
    echo
else
    echo "创建配置文件"
    echo
    mkdir -p /etc/shadowsocks-rust
    echo
    read -p "请输入端口:(默认：9000)" PORT
    echo
    read -p "请输入密码:(默认：125390) " PASSWORD
    echo
    cat <<EOF >/etc/shadowsocks-rust/config.json

      {
          "server":"0.0.0.0",
          "server_port":${PORT:-9000},
          "password":"${PASSWORD:-125390}",
          "timeout":300,
          "method":"aes-128-gcm",
          "nameserver":"8.8.8.8",
          "mode":"tcp_and_udp"
      }
EOF
    echo
fi
echo
if docker ps | grep ss-rust >/dev/null 2>&1; then
    echo "ss-rust 已经启动 🎉 "
    echo
else
    echo "启动 ss-rust"
    docker run -d -p 9000:9000 -p 9000:9000/udp --name ss-rust --restart=always -v /etc/shadowsocks-rust:/etc/shadowsocks-rust teddysun/shadowsocks-rust
fi
echo
echo "查看 ss-rust 运行状态"
echo
docker ps | grep ss-rust
echo

echo "surge 配置文件"
echo
echo "=============================="
echo
echo "ss = ss, $(curl https://api.my-ip.io/ip -s), $(cat /etc/shadowsocks-rust/config.json | jq -r '.server_port'), encrypt-method=$(cat /etc/shadowsocks-rust/config.json | jq -r '.method'),password=$(cat /etc/shadowsocks-rust/config.json | jq -r '.password'),udp-relay=true"
echo
echo "=============================="

echo " 安装完成 🎉 🎉 🎉 "

echo
