#!/usr/bin/env bash

if [[ ! -d /root/snell/ ]]; then
  echo "文件夹已存在 🎉 "
  cd /root/snell
  echo
else
  echo "创建文件夹"
  mkdir -p /root/snell && cd /root/snell
fi
echo
echo "正在安装依赖..."
echo
if type wget unzip >/dev/null 2>&1; then
  echo "依赖已安装 🎉  "
  echo
else
  echo "依赖未安装"
  if [[ -f /etc/redhat-release ]]; then
    yum install wget unzip -y
  else
    apt install wget unzip -y
  fi
fi
echo
if type node </dev/null >/dev/null 2>&1; then
  echo "已安装nodejs 🎉  "
  echo
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
  echo "已安装pm2 🎉 "
  echo
else
  echo "正在安装pm2"
  npm install pm2 -g
fi

if [[ ! -d /root/snell ]]; then
  echo "创建文件夹"
  echo
  mkdir -p /root/snell
else
  echo "文件夹已存在 🎉 "
  cd /root/snell
fi

OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
  OS_ARCH="amd64"
  echo
  echo "当前系统架构为 ${OS_ARCH}"
  echo
elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "aarch64" ]]; then
  OS_ARCH="aarch64"
  echo
  echo "当前系统架构为 ${OS_ARCH}"
else
  OS_ARCH="amd64"
  echo
  echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi
echo
echo "正在下载snell..."
echo
if [[ -f /root/snell/snell-server ]]; then
  echo "snell-server已存在 🎉 "
  echo
else
  echo "snell-server不存在 下载中..."
  echo
  cd /root/snell
  wget https://dl.nssurge.com/snell/snell-server-v4.0.0-linux-${OS_ARCH}.zip -O snell.zip >/dev/null 2>&1
  echo
  echo "正在解压snell..."
  echo
  unzip -o snell.zip && rm -f snell.zip && chmod +x snell-server
fi

if [[ -f /root/snell/snell-server.conf ]]; then
  echo "snell-server.conf已存在 🎉 "
  echo
else
  echo
  echo "snell-server.conf不存在 创建中..."
  cd /root/snell
  echo
  read -p "请输入snell-server的端口:" port
  echo
  cat <<EOF >snell-server.conf
[snell-server]
listen = ${port}
psk = DsU0x9afoOKLoWI1kUYnlxj6tv3YDef
obfs = http
EOF
fi
echo
if [[ $(pm2 list | grep snell-server | wc -l) -gt 0 ]]; then
  echo "snell-server已启动 🎉 "
  echo
else
  echo "正在启动snell..."
  cd /root/snell
  pm2 start ./snell-server -- -c snell-server.conf
fi
echo
echo "正在读取snell配置文件..."
echo
cat /root/snell/snell-server.conf
echo
echo "正在读取snell运行日志..."
echo
pm2 startup systemd && systemctl enable pm2-root && systemctl start pm2-root  && pm2 ls && pm2 log snell-server --lines 10 --raw --nostream 
echo
echo "surge 配置文件"
echo
echo "=============================="
echo
echo "snell = snell,$(curl https://api.my-ip.io/ip -s),"$(cat /root/snell/snell-server.conf | grep "listen" | awk -F "=" '{print $2}' | sed 's/ //g')",psk=$(cat /root/snell/snell-server.conf | grep "psk" | awk -F "=" '{print $2}' | sed 's/ //g'),obfs=$(cat /root/snell/snell-server.conf | grep "obfs" | awk -F "=" '{print $2}' | sed 's/ //g'),version=4, reuse=true"
echo
echo "=============================="
echo
echo " snell 安装完成 🎉 "
echo
