#!/bin/bash
echo -e "\ninstall hysteria\n"
bash <(curl -fsSL https://get.hy2.sh/)
mkdir -p /etc/hysteria/
cat >/etc/hysteria/config.yaml <<EOF
listen: :11443
tls:
  cert: /etc/hysteria/rsa.pem
  key: /etc/hysteria/key.pem
quic:
  initStreamReceiveWindow: 8388608 
  maxStreamReceiveWindow: 8388608 
  initConnReceiveWindow: 20971520 
  maxConnReceiveWindow: 20971520 
  maxIdleTimeout: 30s 
  maxIncomingStreams: 1024 
  disablePathMTUDiscovery: false
bandwidth:
  up: 1 gbps
  down: 1 gbps
ignoreClientBandwidth: false
auth:
  type: password
  password: QI9cLzc/QSXr2nmNGU2lt1/1
masquerade:
  type: proxy
  proxy:
    url: https://news.ycombinator.com/
    rewriteHost: true

EOF
echo -e "\nBBR\n"
cat >/etc/sysctl.conf <<EOF

net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=2
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=2
net.ipv4.tcp_moderate_rcvbuf=1
net.ipv4.tcp_rmem=4096 65536 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
EOF
echo
sysctl -p
echo
echo -e "\ninstall rsa\n"

cat <<EOF >/etc/hysteria/rsa.pem

-----BEGIN CERTIFICATE-----
MIIDJTCCAsqgAwIBAgIUZVP12u9Ahz9HKInUTg7xpioFLoAwCgYIKoZIzj0EAwIw
gY8xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T
YW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTgwNgYDVQQL
Ey9DbG91ZEZsYXJlIE9yaWdpbiBTU0wgRUNDIENlcnRpZmljYXRlIEF1dGhvcml0
eTAeFw0yMzA5MjExNDU4MDBaFw0zODA5MTcxNDU4MDBaMGIxGTAXBgNVBAoTEENs
b3VkRmxhcmUsIEluYy4xHTAbBgNVBAsTFENsb3VkRmxhcmUgT3JpZ2luIENBMSYw
JAYDVQQDEx1DbG91ZEZsYXJlIE9yaWdpbiBDZXJ0aWZpY2F0ZTBZMBMGByqGSM49
AgEGCCqGSM49AwEHA0IABMLyFfY0DKHJG2VdFbi/2aESf7hqQi3yw8Wk5lpLfYPx
98xNqTHzL8+H+0xmjtQJB56l8QbYNj4ja2dNjvvJT3ujggEuMIIBKjAOBgNVHQ8B
Af8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMAwGA1UdEwEB
/wQCMAAwHQYDVR0OBBYEFPxbqe5mcbf8JqyEALCUoAdfY9xeMB8GA1UdIwQYMBaA
FIUwXTsqcNTt1ZJnB/3rObQaDjinMEQGCCsGAQUFBwEBBDgwNjA0BggrBgEFBQcw
AYYoaHR0cDovL29jc3AuY2xvdWRmbGFyZS5jb20vb3JpZ2luX2VjY19jYTAnBgNV
HREEIDAegg4qLmlvMjF3b3Jrcy5jZoIMaW8yMXdvcmtzLmNmMDwGA1UdHwQ1MDMw
MaAvoC2GK2h0dHA6Ly9jcmwuY2xvdWRmbGFyZS5jb20vb3JpZ2luX2VjY19jYS5j
cmwwCgYIKoZIzj0EAwIDSQAwRgIhAJWujsUWShKI7fm7os7BFhZDt6xjHL8zMU9J
2+lJolpEAiEA9oqtduq/oLhSzNsVUv0ODJx4+nGEO9Cg9MAYzyt6DeU=
-----END CERTIFICATE-----

EOF

cat <<EOF >/etc/hysteria/key.pem


-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgGDpjO8FJoqlr3Jqu
ImkkP/iHQUuCvNY9Q9k8IrDEKFyhRANCAATC8hX2NAyhyRtlXRW4v9mhEn+4akIt
8sPFpOZaS32D8ffMTakx8y/Ph/tMZo7UCQeepfEG2DY+I2tnTY77yU97
-----END PRIVATE KEY-----

EOF
echo
echo "Hysteria = hysteria2, $(curl -s -4 http://www.cloudflare.com/cdn-cgi/trace | grep "ip" | awk -F "[=]" '{print $2}'), 11443, password=QI9cLzc/QSXr2nmNGU2lt1/1, skip-cert-verify=true, download-bandwidth=1024"
echo 
systemctl enable hysteria-server.service && systemctl start hysteria-server.service && systemctl status --no-pager hysteria-server.service
echo
echo

