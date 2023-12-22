#！/bin/bash
echo 
echo "安装 docker“

curl -sSL get.docker.com | sh 

echo 
echo
echo ”设置自启动 “

systemctl enable docker  && systemctl start docker
