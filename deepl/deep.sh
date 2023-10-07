#!/bin/bash
echo
mkdir -p $PWD/deepl
echo
echo $PWD/deepl
echo
cd $PWD/deepl
echo
echo "安装 docker-compose"
wget https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo
cat >$PWD/docker-compose.yaml <<EOL
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
