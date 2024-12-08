#!/bin/bash

apt install curl wget unzip -y

wget https://github.com/cnmeeia/caddy/releases/download/v0.4.2/caddy -O /usr/bin/caddy && chmod +x /usr/bin/caddy

cat <<EOF >/etc/systemd/system/caddy.service
[Unit]
Description=Caddy Web Server
Documentation=https://caddyserver.com/docs/
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/bin/caddy run --config /etc/caddy/https.caddyfile --resume
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

if systemctl restart caddy; then
        systemctl enable caddy
        systemctl start caddy
        systemctl status caddy
else
        echo "重启 Caddy 服务失败。"
        exit 1
fi

echo "Caddy 安装和配置成功完成。"

journalctl -u caddy.service -f

caddy fmt --overwrite /etc/caddy/https.caddyfile

cat <<EOF >/etc/caddy/https.caddyfile
new.19510272.xyz {
    reverse_proxy http://127.0.0.1:8008
    tls /opt/caddy/rsa.pem /opt/caddy/key.pem
}

EOF

systemctl daemon-reload && systemctl restart caddy && systemctl status caddy

# (ssl_cert) {
#     tls /opt/caddy/rsa.pem /opt/caddy/key.pem
# }

# ra.19510272.xyz {
#     import ssl_cert

#     route {
#         forward_proxy {
#             basic_auth 1024 $Passwd
#             hide_ip
#             hide_via
#         }
#         file_server
#     }
# }

journalctl -u caddy.service
