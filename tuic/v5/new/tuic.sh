#!/bin/bash

set -euo pipefail
echo
mkdir -p /opt/tuic/v5
echo
cd /opt/tuic/v5
echo
if [ -f "tuic-server" ]; then
    echo "tuic-server 已经存在，跳过下载。"
    else
    echo
    echo "tuic-server 不存在，开始下载。"
#!/bin/bash

set -euo pipefail

# 定义 TUIC Server 版本
readonly TUIC_VERSION="tuic-server-1.0.0"

# 获取系统架构
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  FILE_PATTERN="x86_64-unknown-linux-gnu" ;;
    aarch64) FILE_PATTERN="aarch64-unknown-linux-gnu" ;; 
    armv7l)  FILE_PATTERN="armv7-unknown-linux-gnueabihf" ;;
    i386|i686) FILE_PATTERN="i686-unknown-linux-gnu" ;;
    *)       echo "不支持的架构: $ARCH" && exit 1 ;;
esac

echo "检测到架构: $ARCH"
echo "目标文件模式: $FILE_PATTERN"

# 获取 GitHub Release 信息
RELEASE_INFO=$(curl -s "https://api.github.com/repos/tuic-protocol/tuic/releases/tags/$TUIC_VERSION")

# 提取下载链接（精确匹配架构）
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | jq -r --arg pattern "$FILE_PATTERN" '.assets[] | select(.name | endswith($pattern)) | .browser_download_url')

if [ -z "$DOWNLOAD_URL" ]; then
    echo "未找到适用于架构 $ARCH 的下载链接！"
    exit 1
fi

echo "下载链接: $DOWNLOAD_URL"

# 下载文件
wget -O "/opt/tuic/v5/tuic-server" "$DOWNLOAD_URL"
chmod +x "/opt/tuic/v5/tuic-server"

echo "下载完成！"

fi
echo

cat <<EOF >/opt/tuic/v5/key.pem
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQguPFkhs62WG/6QUrD
LGwv6J5f8Fgqs6+jXpdT3JEJm9+hRANCAAQLlIoST1T1AreAZI+T9ZviUD3gKK23
y/aPSsrIydKd6tpLNKpHtQmFsaYA+eOKOLVbTwo2ZUCloE7vuJtHtUwn
-----END PRIVATE KEY-----
EOF

cat <<EOF >/opt/tuic/v5/rsa.pem
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIUcsRZmBnb5rxvIAvZUSp5ZUcznD0wDQYJKoZIhvcNAQEL
BQAwgagxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH
Ew1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZGZsYXJlLCBJbmMuMRswGQYD
VQQLExJ3d3cuY2xvdWRmbGFyZS5jb20xNDAyBgNVBAMTK01hbmFnZWQgQ0EgYmNj
NzZhZTQ0NzNlZGRmMjBmOGQzMzZiZDI1ODlhOTIwHhcNMjQxMTE2MDE0OTAwWhcN
MzkxMTEzMDE0OTAwWjAiMQswCQYDVQQGEwJVUzETMBEGA1UEAxMKQ2xvdWRmbGFy
ZTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABAuUihJPVPUCt4Bkj5P1m+JQPeAo
rbfL9o9KysjJ0p3q2ks0qke1CYWxpgD544o4tVtPCjZlQKWgTu+4m0e1TCejgbsw
gbgwEwYDVR0lBAwwCgYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU
PDzGgMvZydBT/4Gg8er6HsvJpIgwHwYDVR0jBBgwFoAUTG0l5xgFvN2l4ELuPunA
euSCf0cwUwYDVR0fBEwwSjBIoEagRIZCaHR0cDovL2NybC5jbG91ZGZsYXJlLmNv
bS81NTI0OTViZi05MDkyLTQxNjctOTk1MS1kODI4MDY3N2Y1MzMuY3JsMA0GCSqG
SIb3DQEBCwUAA4IBAQAXZ6C/LkKJFdRARknGSpDUvxo43oIb2Zn4LfikVyx90FuK
RyDFffo2/f30Op3RQmTA1rKeSSb/3+0BQqyLRrN8p6Rhk5+QU6BKZ/d3uYbiELsf
kJSh+WA2EvcX2gecQaBgItmWIyr5Iy70svh+PyY1tqQFYs0UNU9Un0A973sd/GP+
hHNTEFHT8P6SwzaxaKoq83bpMEP0lmWwH88Qcnf6SqhAk1xyUGRx3IbGYKwdTd0F
uHbsVOmNzN2m2GMGLKBBINr6RB3K9i5TO4QtDp/VCtrxWXciSzmc57fJ02CQMu3c
96+5FaMZQFVqx4rJNJFxApA2hhlQvHKldPIDQjBF
-----END CERTIFICATE-----
EOF

echo





if [[ -f /opt/tuic/v5/tuic.conf ]]; then
      echo
      echo "配置文件已存在 🎉"
      echo
else
      echo "正在创建配置文件"

      echo
      echo "随机密码"
      password="$(openssl rand -base64 12)"
      echo
      echo "随机端口"
      port="$((RANDOM % 40001 + 10000))"
      echo

      cat >/opt/tuic/v5/tuic.conf <<EOF
{
    "server": "0.0.0.0:${port}",
    "users": {"be998b07-ee5e-4c34-aa8d-2b2baad5b428": "${password}"},
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

systemctl daemon-reload
systemctl enable tuic
systemctl start tuic
systemctl start tuic

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
echo Tuic V5= tuic-v5, $(curl api.ipify.org), $(jq -r '.server | split(":") | .[1]' /opt/tuic/v5/tuic.conf), sni=$(cat /opt/tuic/v5/domain.txt), server-cert-fingerprint-sha256=$(cd /opt/tuic/v5 && openssl x509 -fingerprint -sha256 -in rsa.pem -noout | cut -d = -f 2),uuid=$(jq -r '.users | keys[]' /opt/tuic/v5/tuic.conf), alpn=h3,password=$(jq -r '.users | to_entries[] | .value' /opt/tuic/v5/tuic.conf),version=5
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
    port: $(cat /opt/tuic/v5/tuic.conf | jq -r '.server' | awk -F':' '{print $2}')
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
