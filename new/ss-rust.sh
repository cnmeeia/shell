#!/usr/bin/env bash

# 安装依赖
type jq >/dev/null 2>&1 && echo -e "\njq 已经安装 🎉" || (
  echo -e "\n安装 jq"
  apt install jq -y >/dev/null 2>&1 || yum install jq -y >/dev/null 2>&1
)
echo

type docker >/dev/null 2>&1 && echo -e "docker 已经安装 🎉\n" || (
  echo -e "安装 docker"
  curl -sSL get.docker.com | sh
  echo -e "设置 docker 开启启动"
  systemctl enable docker && systemctl start docker
)
echo

type docker-compose >/dev/null 2>&1 && echo -e "docker-compose 已经安装 🎉\n" || (
  echo -e "安装 docker-compose"
  curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
)
echo

# 拉取镜像
docker images | grep shadowsocks-rust >/dev/null 2>&1 && echo -e "shadowsocks-rust 镜像已经存在 🎉\n" || (
  echo -e "拉取 shadowsocks-rust 镜像"
  docker pull teddysun/shadowsocks-rust
)
echo

# 创建配置文件
if [ -f /etc/shadowsocks-rust/config.json ]; then
  echo -e "配置文件已经存在 🎉\n"
else
  echo -e "创建配置文件\n"
  mkdir -p /etc/shadowsocks-rust
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
fi
echo

# 启动容器
docker ps | grep ss-rust >/dev/null 2>&1 && echo -e "ss-rust 已经启动 🎉\n" || (
  echo -e "启动 ss-rust"
  docker run -d -p 9000:9000 -p 9000:9000/udp --name ss-rust --restart=always -v /etc/shadowsocks-rust:/etc/shadowsocks-rust teddysun/shadowsocks-rust
)
echo

# 查看运行状态
echo -e "查看 ss-rust 运行状态\n"
docker ps | grep ss-rust
echo

# 输出 Surge 配置文件
echo -e "surge 配置文件\n"
echo "=============================="
echo
echo "ss = ss, $(curl https://api.my-ip.io/ip -s), $(cat /etc/shadowsocks-rust/config.json | jq -r '.server_port'), encrypt-method=$(cat /etc/shadowsocks-rust/config.json | jq -r '.method'),password=$(cat /etc/shadowsocks-rust/config.json | jq -r '.password'),udp-relay=true"
echo
echo "=============================="



echo -e "安装完成 🎉 🎉 🎉\n"
