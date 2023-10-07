#!/bin/bash
echo
mkdir -p $PWD/deepl
echo
echo $PWD/deepl
echo
cd $PWD/deepl
echo
if type docker-compose >/dev/null 2>&1; then
    echo "docker-compose 已经安装 🎉 "
    echo
else
    echo "安装 docker-compose"
    curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi
echo
cat >$PWD/deepl/docker-compose.yaml <<EOL
version: "3.8"
services:
  deepl:
    restart: always
    ports:
      - "12311:80"
    container_name: deepl
    image: "mick2019/deepl:latest"
EOL
echo
docker-compose up -d
echo
