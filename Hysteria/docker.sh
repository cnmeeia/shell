#!/bin/bash
echo
mkdir -p /etc/hysteria
echo 
echo "创建"
echo
cat <<EOF > /etc/hysteria/config.yaml

listen: :33659
tls:
  cert: /etc/hysteria/rsa.pem
  key: /etc/hysteria/key.pem
auth:
  type: password
  password: PuzxVhZBqpq1i61tdXDuQWrNk
masquerade:
  type: proxy
  file:
    dir: /www/masq
  proxy:
    url: https://news.ycombinator.com/
    rewriteHost: true
  string:
    content: hello stupid world
    headers:
      content-type: text/plain
      custom-stuff: ice cream so good
    statusCode: 200
bandwidth:
  up: 0 gbps
  down: 0 gbps
udpIdleTimeout: 90s
EOF
echo
echo ”创建 docker-compose 文件”
echo
cat <<EOF > /etc/hysteria/compose.yaml
services:
  hysteria:
    image: tobyxdd/hysteria
    container_name: hysteria
    restart: always
    network_mode: "host"
    volumes:
      - acme:/acme
      - /etc/hysteria/config.yaml:/etc/hysteria.yaml
      - /etc/hysteria/rsa.pem:/etc/hysteria/rsa.pem
      - /etc/hysteria/key.pem:/etc/hysteria/key.pem
    command: ["server", "-c", "/etc/hysteria.yaml"]
volumes:
  acme:
EOF
echo
echo “密钥”
echo
cat <<EOF > /etc/hysteria/key.pem

-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQguPFkhs62WG/6QUrD
LGwv6J5f8Fgqs6+jXpdT3JEJm9+hRANCAAQLlIoST1T1AreAZI+T9ZviUD3gKK23
y/aPSsrIydKd6tpLNKpHtQmFsaYA+eOKOLVbTwo2ZUCloE7vuJtHtUwn
-----END PRIVATE KEY-----

EOF 

echo
echo “证书”
echo

cat <<EOF > /etc/hysteria/rsa.pem

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
echo "启动 docker 容器..."
echo
cd /etc/hysteria && docker compose up -d 
echo
echo "查看日志..."
echo
docker logs --tail 10 hysteria

echo
echo
echo
