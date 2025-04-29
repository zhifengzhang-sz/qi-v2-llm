#!/bin/bash

echo '{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn/",
    "https://dockerhub.azk8s.cn/",
    "https://docker.nju.edu.cn/",
    "https://registry.docker-cn.com/",
    "https://hub-mirror.c.163.com/",
    "https://mirror.baidubce.com/"
  ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for China mode. Docker service restarted."
