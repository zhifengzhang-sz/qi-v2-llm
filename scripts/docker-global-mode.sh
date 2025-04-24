#!/bin/bash

echo '{
  "registry-mirrors": []
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for global mode. Docker service restarted."
