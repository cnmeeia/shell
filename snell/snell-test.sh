#!/usr/bin/env bash

# 设置默认文件夹路径
folder="/root/snell"

# 检查文件夹是否存在，如果存在则进入文件夹
if [ -d "$folder" ]; then
  echo "文件夹已存在 🎉"
  cd "$folder"
# 否则创建文件夹并进入
else
  echo "创建文件夹"
  mkdir -p "$folder" && cd "$folder"
fi

# 检查 wget 和 unzip 是否已安装
echo "正在安装 wget 和 unzip ..."
if type wget unzip >/dev/null 2>&1; then
  echo "wget 和 unzip 已安装 🎉"
else
  echo "wget 和 unzip 未安装，正在安装..."
  # 根据系统类型选择安装命令
  if [[ -f /etc/redhat-release ]]; then
    yum install wget unzip -y
  else
    apt install wget unzip -y
  fi
fi

# 检查 nodejs 是否已安装
echo "正在安装 nodejs ..."
if type node >/dev/null 2>&1; then
  echo "nodejs 已安装 🎉"
else
  echo "nodejs 未安装，正在安装..."
  # 根据系统类型选择安装命令
  if type apt >/dev/null 2>&1; then
    apt install -y nodejs
  elif type yum >/dev/null 2>&1; then
    yum install -y nodejs
  else
    echo "不支持的操作系统！"
    exit 1
  fi
fi

# 检查 npm 是否已安装，如果未安装则安装
echo "正在安装 npm ..."
if ! type npm >/dev/null 2>&1; then
  echo "npm 未安装，正在安装..."
  # 根据系统类型选择安装命令
  if command -v apt >/dev/null 2>&1; then
    apt update
    apt install -y npm
  elif command -v yum >/dev/null 2>&1; then
    yum update
    yum install -y npm
  else
    echo "不支持该系统的包管理器"
    exit 1
  fi
  echo "npm 安装完成！"
else
  echo "npm 已安装"
fi

# 检查 pm2 是否已安装，如果未安装则安装
echo "正在安装 pm2 ..."
if type pm2 >/dev/null 2>&1; then
  echo "pm2 已安装 🎉"
else
  echo "pm2 未安装，正在安装..."
  npm install pm2 -g
fi

# 检查 snell 文件夹是否存在，如果存在则进入
if [[ -d /root/snell ]]; then
  echo "文件夹已存在 🎉"
  cd /root/snell
# 否则创建文件夹并进入
else
  echo "创建文件夹"
  mkdir -p /root/snell
  cd /root/snell
fi

# 获取系统架构
OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
  OS_ARCH="amd64"
  echo "当前系统架构为 ${OS_ARCH}"
elif [[ ${OS_ARCH} == "aarch64" ]]; then
  OS_ARCH="aarch64"
  echo "当前系统架构为 ${OS_ARCH}"
else
  OS_ARCH="amd64"
  echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi

# 下载 snell-server
echo "正在下载 snell-server ..."
if [[ -f /root/snell/snell-server ]]; then
  echo "snell-server 已存在 🎉"
else
  echo "snell-server 不存在，正在下载..."
  # 使用 wget 下载 snell-server
  wget https://dl.nssurge.com/snell/snell-server-v4.1.0-linux-${OS_ARCH}.zip -O snell.zip >/dev/null 2>&1

  echo "正在解压 snell-server ..."
  # 解压 snell-server
  rm -rf snell-server && unzip -o snell.zip && rm -f snell.zip && chmod +x snell-server
fi

# 检查 snell-server.conf 是否存在，如果不存在则创建
echo "正在创建 snell-server.conf ..."
if [[ -f /root/snell/snell-server.conf ]]; then
  echo "snell-server.conf 已存在 🎉"
else
  echo "snell-server.conf 不存在，正在创建..."
  # 获取用户输入的端口号
  read -p "请输入 snell-server 的端口: " port
  # 生成随机的 PSK 密钥
  psk=$(openssl rand -hex 32)
  echo "随机生成的 PSK 密钥为: $psk"
  # 创建 snell-server.conf 文件
  cat <<EOF >snell-server.conf
[snell-server]
listen = 0.0.0.0:${port}
psk = ${psk}
dns = 1.1.1.1, 8.8.8.8, 2001:4860:4860::8888
ipv6 = false
obfs = http
EOF
fi

# 检查 snell-server 是否已启动，如果未启动则启动
echo "正在启动 snell-server ..."
if [[ -n $(pm2 pid snell-server) ]]; then
  echo "snell-server 已启动 🎉"
else
  echo "snell-server 未启动，正在启动..."
  cd /root/snell && pm2 start ./snell-server -- -c /root/snell/snell-server.conf
fi

# 打印 snell-server.conf 内容
echo "正在读取 snell-server.conf ..."
cat /root/snell/snell-server.conf

# 打印 snell-server 运行日志
echo "正在读取 snell-server 运行日志 ..."
pm2 ls && pm2 log snell-server --lines 10 --raw --nostream

# 打印 Surge 配置示例
echo "Surge 配置示例 🎉"
echo "=============================="
echo "snell = snell,$(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}'),"$(cat /root/snell/snell-server.conf | grep "listen" | awk -F ":" '{print $2}' | sed 's/ //g')",psk=$(cat /root/snell/snell-server.conf | grep "psk" | awk -F "=" '{print $2}' | sed 's/ //g'),obfs=$(cat /root/snell/snell-server.conf | grep "obfs" | awk -F "=" '{print $2}' | sed 's/ //g'),version=4, reuse=true"
echo "=============================="

# 完成提示
echo "snell 安装完成 🎉"
