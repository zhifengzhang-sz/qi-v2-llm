# Docker & GitHub Configuration for Network Restrictions

This document explains how to configure Docker and GitHub mirrors for network-restricted environments. The updated devcontainer structure with base images and MCP environment works seamlessly with these network configurations.

## 1. Docker Registry Mirrors

For users in regions with restricted Docker Hub access, we provide scripts to switch between global and region-specific Docker registry mirrors.

### Using Registry Mirrors

```bash
# Switch to China-friendly Docker registry mirrors
npm run docker:china

# Switch back to global Docker registry
npm run docker:global
```

### How It Works

The `docker-china-mode.sh` script configures Docker to use multiple China-based registry mirrors:

```bash
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
```

And `docker-global-mode.sh` reverts to direct Docker Hub access:

```bash
#!/bin/bash

echo '{
  "registry-mirrors": []
}' | sudo tee /etc/docker/daemon.json

sudo systemctl restart docker
echo "Docker configured for global mode. Docker service restarted."
```

## 2. GitHub and Package Manager Mirrors

Similar to Docker, we provide scripts to switch between global and region-specific settings for GitHub, npm, and pip.

### Using GitHub Mirrors

```bash
# Configure GitHub, npm, and pip to use China mirrors
npm run github:china

# Revert to global settings
npm run github:global
```

### How It Works

The `github-china-mode.sh` script configures multiple services:

```bash
#!/bin/bash

# Configure Git to use mirrors for GitHub
git config --global url."https://ghproxy.com/https://github.com/".insteadOf "https://github.com/"
git config --global url."https://gitclone.com/github.com/".insteadOf "git@github.com:"

# Configure npm to use mirrors for GitHub packages
npm config set registry https://registry.npmmirror.com

# Configure pip to use mirrors
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/

echo "GitHub, npm and pip configured for China mode."
```

And `github-global-mode.sh` reverts these settings:

```bash
#!/bin/bash

# Reset Git to use direct GitHub URLs
git config --global --unset url."https://ghproxy.com/https://github.com/".insteadOf
git config --global --unset url."https://gitclone.com/github.com/".insteadOf

# Reset npm to default registry
npm config delete registry

# Reset pip to default
pip config unset global.index-url

echo "GitHub, npm and pip reset to global mode."
```

## 3. Combined Network Configuration

For convenience, we provide combined commands for full network configuration:

```bash
# Configure all services for China networks
npm run network:china

# Revert everything to global settings
npm run network:global
```

## 4. Docker Compose Installation

If Docker Compose is not available or not working correctly in your environment:

```bash
# Install Docker Compose locally
npm run compose:install
```

This uses our network-aware script that automatically detects if you need China mirrors:

```bash
#!/bin/bash

echo "Installing Docker Compose..."

# For China networks, try mirrors first
if ping -c 1 -W 2 ghproxy.com &> /dev/null; then
  echo "Using China mirror for Docker Compose..."
  COMPOSE_URL="https://ghproxy.com/https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64"
else
  echo "Using direct GitHub URL..."
  COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64"
fi

# Create Docker CLI plugins directory
mkdir -p ~/.docker/cli-plugins/

# Try to download with progress
echo "Downloading from: $COMPOSE_URL"
if ! curl -SL --progress-bar "$COMPOSE_URL" -o ~/.docker/cli-plugins/docker-compose; then
  echo "Failed to download Docker Compose."
  echo "Error: Network connectivity issue. You may need to configure network settings."
  exit 1
fi

# Make executable
chmod +x ~/.docker/cli-plugins/docker-compose

# Create symlink for backward compatibility
echo "Creating symlink to /usr/local/bin/docker-compose..."
sudo ln -sf ~/.docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Verify installation
echo "Verifying installation..."
if docker compose version; then
  echo "Docker Compose V2 installed successfully."
elif docker-compose --version; then
  echo "Docker Compose installed successfully (V1 compatibility)."
else
  echo "Docker Compose installation seems to have failed. Please check errors above."
  exit 1
fi
```

## 5. Network Compatibility with the New Architecture

The improved devcontainer structure with the base image and specialized environments (including MCP) is designed to work seamlessly with all network configurations.

### Network Testing in Containers

All devcontainers include a network testing utility:

```bash
# Test connectivity to key services
test-network
```

This command checks connectivity to GitHub and Docker Hub, helping diagnose network issues inside your containers.

### Building Containers in Restricted Networks

When building the containers in a network-restricted environment:

1. Configure network settings first:
   ```bash
   npm run network:china
   ```

2. Then run the setup script:
   ```bash
   npm run setup
   ```

The setup process will build the base image first, then the specialized environments, using the configured network settings.