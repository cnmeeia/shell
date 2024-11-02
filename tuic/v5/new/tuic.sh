#!/usr/bin/env bash
echo

if [[ ! -d /opt/tuic/v5 ]]; then
    echo
    echo "创建文件夹"
    mkdir -p /opt/tuic/v5 && cd /opt/tuic/v5
else
    echo
    echo "文件夹已存在 🎉 "
    cd /opt/tuic/v5
fi
echo 请确认 /opt/tuic/v5 文件夹有域名证书格式是 rsa.pem key.pem

if [[ ! -d /opt/tuic/v5 ]]; then
    echo
    echo "创建文件夹"
    mkdir -p /opt/tuic/v5 && cd /opt/tuic/v5
else
    echo
    echo "文件夹已存在 🎉 "
    cd /opt/tuic/v5
fi
echo
apt update && apt install jq wget curl -y
echo

echo
OS_ARCH=$(arch)
if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
    OS_ARCH="x86_64"
    echo
    echo "当前系统架构为 ${OS_ARCH}"
elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "aarch64" ]]; then
    OS_ARCH="aarch64"
    echo "当前系统架构为 ${OS_ARCH}"
else
    echo
    OS_ARCH="amd64"
    echo "检测系统架构失败，使用默认架构: ${OS_ARCH}"
fi
echo

echo "正在下载tuic..."
if [[ -f /opt/tuic/v5/tuic-server ]]; then
    echo
    echo "tuic-server 已存在 🎉"
else

    USER=EAimTY
    REPO=tuic

    response=$(curl --silent "https://api.github.com/repos/$USER/$REPO/releases")
    pre_release=$(echo "$response" | jq '.[] | select(.prerelease == false) | .tag_name' | head -n1 | sed -e 's/^"//' -e 's/"$//')

    if [[ "$pre_release" == "null" ]]; then
        echo "There is no pre-release version available."
        exit 0
    fi
    echo "The latest pre-release version is: $pre_release"
fi
echo

echo
if [[ -f /opt/tuic/v5/tuic-server ]]; then
    echo
    echo "tuic-server 已存在 🎉"

else
    echo
    echo "最新版本为 ${pre_release}"
    echo
    echo "正在下载tuic-server-&{pre_release}..."
    echo
    wget https://github.com/EAimTY/tuic/releases/download/${pre_release}/${pre_release}-${OS_ARCH}-unknown-linux-gnu -O tuic-server && chmod +x tuic-server
fi

echo
if [[ -f /opt/tuic/v5/domain.txt ]]; then
    echo "域名已经存在"
else
    read -p "请输入域名: " DOMAIN
    echo "${DOMAIN}" >/opt/tuic/v5/domain.txt
fi
echo
if [[ -f /opt/tuic/v5/rsa.pem ]]; then
    echo "域名证书已经配置"
else
    echo "错误：/opt/tuic/v5/rsa.pem 文件不存在，请检查配置。"
    exit 1
fi
echo
echo

echo "正在创建配置文件..."

if [[ -f /opt/tuic/v5/tuic.conf ]]; then
    echo
    echo "配置文件已存在🎉"
    echo
else
    echo "正在创建配置文件"
    echo
    read -p "请输入密码:(默认125390) " password
    read -p "请输入端口:(默认15443) " port

    cat >/opt/tuic/v5/tuic.conf <<EOF
{
    "server": "0.0.0.0:$port",
    "users": {"be998b07-ee5e-4c34-aa8d-2b2baad5b428": "$password"},
    "certificate": "/opt/tuic/v5/rsa.pem",
    "private_key": "/opt/tuic/v5/key.pem",
    "congestion_control": "bbr",
    "alpn": ["h3"],
    "udp_relay_ipv6": false,
    "zero_rtt_handshake": false,
    "auth_timeout": "3s",
    "max_idle_time": "10s",
    "max_external_packet_size": 1500,
    "gc_interval": "3s",
    "gc_lifetime": "15s",
    "log_level": "warn"
}
EOF

fi

echo echo "正在创建 tuic 服务文件..."
echo
if [[ -f /etc/systemd/system/tuic.service ]]; then
    echo "tuic 服务文件已存在🎉"
else
    echo "正在创建 tuic 服务文件"

    cat <<EOF >/etc/systemd/system/tuic.service
[Unit]
Description=tuic
After=network.target
[Service]
Type=simple
ExecStart=/opt/tuic/v5/tuic-server -c /opt/tuic/v5/tuic.conf
[Install]
WantedBy=multi-user.target

EOF
fi
echo
echo "正在启动 tuic 服务..."
systemctl daemon-reload && systemctl enable tuic && systemctl start tuic
echo
echo
echo "配置 tuic ssl 证书指纹 "
echo
echo "$(cd /opt/tuic/v5 && openssl x509 -fingerprint -sha256 -in rsa.pem -noout | cut -d = -f 2)"
echo
echo

uuids=($(jq -r '.users | keys_unsorted[]' /opt/tuic/v5/tuic.conf))

for uuid in "${uuids[@]}"; do
    password=$(jq -r ".users[\"$uuid\"]" /opt/tuic/v5/tuic.conf)
    echo "UUID: ${uuid//\"/}, Password: $password"
done

echo
echo "============ surge 简易配置示使用 =============="
echo
echo
echo Tuic V5= tuic, $(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}'), "$(jq -r '.server | split(":")[1]' "/opt/tuic/v5/tuic.conf")", sni=$(cat /opt/tuic/v5/domain.txt), server-cert-fingerprint-sha256=$(cd /opt/tuic/v5 && openssl x509 -fingerprint -sha256 -in rsa.pem -noout | cut -d = -f 2),uuid=$uuid, alpn=h3,password=$password,version=5
echo
echo
echo "=============================================="
echo
echo

echo "============ stash 简易配置示例 =============="
echo "
  - name: stash tuic
    type: tuic
    server: $(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}')
    port: $(jq -r '.server | split(":")[1]' "/opt/tuic/v5/tuic.conf")
    token: "$(cat /opt/tuic/v5/tuic.conf | jq -r '.users | to_entries[] | "\(.key) \(.value)"')"
    udp: true
    skip-cert-verify: true
    sni: "$(cat /opt/tuic/v5/domain.txt)"
    alpn:
      - h3"
echo
echo "=============================================="
echo
echo "tuic-server-0.8.5  安装完成 🎉 🎉 🎉 "
echo
echo
