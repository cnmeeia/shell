#!/usr/bin/env bash

mkdir -p /root/snell && cd /root/snell

echo
echo "正在安装依赖..."
echo
if type wget unzip >/dev/null 2>&1; then
  echo "依赖已安装 🎉  "
  echo
else
  echo "依赖未安装"
  if [[ -f /etc/redhat-release ]]; then
    yum update && yum install wget unzip -y
  else
    apt update && apt install wget unzip -y
  fi
fi
echo

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
  rm -rf snell-server && unzip -o snell.zip && rm -f snell.zip && chmod +x snell-server
fi
echo

cd /root/snell
echo
echo yes | ./snell-server
echo
echo "obfs = http" >>snell-server.conf
echo
echo "后台运行snell..."
echo
apt install screen -y && screen -dmS snell ./snell-server   

echo
echo "surge 配置文件"
echo
echo "=============================="
echo
echo "snell = snell,$(curl https://api.my-ip.io/ip -s),"$(cat /root/snell/snell-server.conf | grep "listen" | awk -F ":" '{print $2}' | sed 's/ //g')",psk=$(cat /root/snell/snell-server.conf | grep "psk" | awk -F "=" '{print $2}' | sed 's/ //g'),obfs=$(cat /root/snell/snell-server.conf | grep "obfs" | awk -F "=" '{print $2}' | sed 's/ //g'),version=4, reuse=true"
echo
echo "=============================="
echo
echo " snell 安装完成 🎉 "
echo
