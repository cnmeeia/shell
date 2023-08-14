#!/bin/bash
echo
mkdir -p $PWD/deepl
echo
echo $PWD/deepl
echo
cd $PWD/deepl
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
