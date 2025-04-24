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
