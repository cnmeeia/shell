#!/usr/bin/env bash
# 安装 jq
install_jq() {
  if ! type jq >/dev/null 2>&1; then
    echo "安装 jq"
    if type apt >/dev/null 2>&1; then
      apt install jq -y >/dev/null 2>&1
    elif type yum >/dev/null 2>&1; then
      yum install jq -y >/dev/null 2>&1
    else
      echo "无法安装 jq：未知的包管理器"
      exit 1
    fi
  else
    echo "jq 已经安装 🎉"
  fi
}
# 安装 docker
install_docker() {
  if ! type docker >/dev/null 2>&1; then
    echo "安装 docker"
    curl -sSL get.docker.com | sh >/dev/null 2>&1
    echo "设置 docker 开机启动"
    systemctl enable docker && systemctl start docker
  else
    echo "docker 已经安装 🎉"
  fi
}
# 安装 docker-compose
install_docker_compose() {
  if ! type docker-compose >/dev/null 2>&1; then
    echo "安装 docker-compose"
    wget -q https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  else
    echo "docker-compose 已经安装 🎉"
  fi
}
# 拉取 shadowsocks-rust 镜像
pull_shadowsocks_rust_image() {
  if ! docker images | grep shadowsocks-rust >/dev/null 2>&1; then
    echo "拉取 shadowsocks-rust 镜像"
    docker pull teddysun/shadowsocks-rust
  else
    echo "shadowsocks-rust 镜像已经存在 🎉"
  fi
}
# 创建配置文件
create_config_file() {
  if [ ! -f /etc/shadowsocks-rust/config.json ]; then
    echo "创建配置文件"
    mkdir -p /etc/shadowsocks-rust
    read -p "请输入端口（默认：9000）: " PORT
    PORT=${PORT:-9000}
    read -p "请输入密码（默认：125390）: " PASSWORD
    PASSWORD=${PASSWORD:-125390}
    cat <<EOF >/etc/shadowsocks-rust/config.json
{
  "server": "0.0.0.0",
  "server_port": $PORT,
  "password": "$PASSWORD",
  "timeout": 300,
  "method": "aes-128-gcm",
  "nameserver": "8.8.8.8",
  "mode": "tcp_and_udp"
}
EOF
  else
    echo "配置文件已经存在 🎉"
  fi
}
# 启动 ss-rust
start_ss_rust() {
  if ! docker ps | grep ss-rust >/dev/null 2>&1; then
    echo "启动 ss-rust"
    docker run -d -p 9000:9000 -p 9000:9000/udp --name ss-rust --restart=always -v /etc/shadowsocks-rust:/etc/shadowsocks-rust teddysun/shadowsocks-rust
  else
    echo "ss-rust 已经启动 🎉"
  fi
}
# 查看 ss-rust 运行状态
check_ss_rust_status() {
  echo "查看 ss-rust 运行状态"
  docker ps | grep ss-rust
}
# 输出 surge 配置文件
output_surge_config() {
  echo "surge 配置文件"
  echo "=============================="
  echo "ss = ss, $(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}'), $(cat /etc/shadowsocks-rust/config.json | jq -r '.server_port'), encrypt-method=$(cat /etc/shadowsocks-rust/config.json | jq -r '.method'),password=$(cat /etc/shadowsocks-rust/config.json | jq -r '.password'),udp-relay=true"
  echo "=============================="
}
# 主程序
main() {
  install_jq
  install_docker
  install_docker_compose
  pull_shadowsocks_rust_image
  create_config_file
  start_ss_rust
  check_ss_rust_status
  output_surge_config
  echo "安装完成 🎉 🎉 🎉"
}
main