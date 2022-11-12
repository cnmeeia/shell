#!/usr/bin/env bash

if [[ ! -d /root/snell/ ]]; then
  echo "文件夹已存在 🎉 "
  cd /root/snell

else
  echo "创建文件夹"
  mkdir -p /root/snell && cd /root/snell
fi

echo "正在安装依赖..."
if type wget unzip >/dev/null 2>&1; then
  echo "依赖已安装 🎉  "
else
  echo "依赖未安装"
  if [[ -f /etc/redhat-release ]]; then
    yum install wget unzip -y
  else
    apt install wget unzip -y
  fi
fi

if type node </dev/null >/dev/null 2>&1; then
  echo "已安装nodejs 🎉 🎉 "
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
  echo "已安装pm2 🎉 🎉 🎉 "
else
  echo "正在安装pm2"
  npm install pm2 -g
fi

if [[ ! -d /root/snell ]]; then
  echo "创建文件夹"
  mkdir -p /root/snell
else
  echo "文件夹已存在 🎉 🎉 🎉 🎉 "
  cd /root/snell
fi

OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
  OS_ARCH="amd64"
  echo "当前系统架构为 ${OS_ARCH}"
elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "aarch64" ]]; then
  OS_ARCH="aarch64"
  echo "当前系统架构为 ${OS_ARCH}"
else
  OS_ARCH="amd64"
  echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi

echo "正在下载snell..."

if [[ -f /root/snell/snell-server ]]; then
  echo "snell-server已存在 🎉 🎉 🎉 🎉 🎉"
else
  echo "snell-server不存在 下载中..."
  cd /root/snell
  wget https://dl.nssurge.com/snell/snell-server-v4.0.0-linux-${OS_ARCH}.zip -O snell.zip >/dev/null 2>&1
  echo "正在解压snell..."
  rm -rf snell-server && unzip -o snell.zip && rm -f snell.zip && chmod +x snell-server
fi

if [[ -f /root/snell/snell-server.conf ]]; then
  echo "snell-server.conf已存在 🎉 🎉 🎉 🎉 🎉 🎉"
else
  echo "snell-server.conf不存在 创建中..."
  cd /root/snell
  read -p "请输入snell-server的端口:" port
  cat <<EOF >snell-server.conf
[snell-server]
listen = ${port}
psk = DsU0x9afoOKLoWI1kUYnlxj6tv3YDef
obfs = http
EOF
fi

if [[ $(pm2 list | grep snell-server | wc -l) -gt 0 ]]; then
  echo "snell-server已启动 🎉 🎉 🎉 🎉 🎉 🎉 🎉"
else
  echo "正在启动snell..."
  cd /root/snell
  pm2 start ./snell-server -- -c snell-server.conf
fi

echo "正在设置开机自启..."
pm2 save
pm2 ls

echo "读取snell配置..."

echo "正在读取snell配置文件..."

cat /root/snell/snell-server.conf

echo "正在读取snell运行日志..."

pm2 log snell-server --lines 10 --raw --nostream

echo "snell安装完成 🎉 🎉 🎉 🎉 🎉 🎉 🎉 "



