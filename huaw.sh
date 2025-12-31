#!/bin/bash


cat > /etc/apt/sources.list << 'EOF'
deb http://repo.huaweicloud.com/debian/ bullseye main contrib non-free
deb-src http://repo.huaweicloud.com/debian/ bullseye main contrib non-free

deb http://repo.huaweicloud.com/debian/ bullseye-updates main contrib non-free
deb-src http://repo.huaweicloud.com/debian/ bullseye-updates main contrib non-free

deb http://repo.huaweicloud.com/debian-security bullseye-security main contrib non-free
deb-src http://repo.huaweicloud.com/debian-security bullseye-security main contrib non-free
EOF


apt clean && apt update