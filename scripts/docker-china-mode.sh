#!/bin/bash

echo '{
  "registry-mirrors": [
    "https://mirrors.aliyun.com/docker-ce/registry.txt",
    "https://mirrors.tencent.com/docker-ce/registry.list",
    "https://mirror.sjtu.edu.cn/docker/mirrors.json"
  ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for China mode. Docker service restarted."
