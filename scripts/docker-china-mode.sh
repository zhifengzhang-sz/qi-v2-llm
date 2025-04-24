#!/bin/bash

echo '{
  "registry-mirrors": [
    "https://registry.docker-cn.com/",
    "https://hub-mirror.c.163.com/",
    "https://mirror.baidubce.com/"
  ]
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for China mode. Docker service restarted."
