#!/bin/bash
if [[ -f /usr/local/bin/ssserver ]]; then
      echo "文件已经存在"
else
      wget https://github.com/cnmeeia/shad/raw/refs/heads/main/release/shadowsocks-rust-binaries.tar.gz

      tar -zvxf shadowsocks-rust-binaries.tar.gz -C /usr/local/bin/
fi
mkdir -p /etc/shadowsocks
if [[ -f /etc/shadowsocks/config.json ]]; then
      echo "配置文件已经存在"
else
      password=$(openssl rand -base64 32)
      cat <<EOF >/etc/shadowsocks/config.json
{
    "server": "0.0.0.0",
    "server_port": 1024,
    "password": "$password",
    "timeout": 600,
    "method": "2022-blake3-chacha20-poly1305"
}
EOF
fi

if [[ -f /etc/systemd/system/shadowsocks.service ]]; then

      echo "配置文件已存在"
else

      cat <<EOF >/etc/systemd/system/shadowsocks.service

[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json
Restart=on-abort

[Install]
WantedBy=multi-user.target

EOF
fi

systemctl daemon-reload

systemctl start shadowsocks

systemctl enable shadowsocks

systemctl status shadowsocks
