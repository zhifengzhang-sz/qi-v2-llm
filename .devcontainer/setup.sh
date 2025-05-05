#!/bin/bash
# filepath: /home/zzhang/dev/qi/github/qi-v2-llm/.devcontainer/setup.sh

# Capture local user info
LOCAL_USERNAME=$(whoami)
LOCAL_USER_UID=$(id -u)
LOCAL_USER_GID=$(id -g)

# Create a .env file for docker-compose
cat > .devcontainer/.env <<EOF
LOCAL_USERNAME=$LOCAL_USERNAME
LOCAL_USER_UID=$LOCAL_USER_UID
LOCAL_USER_GID=$LOCAL_USER_GID
EOF

echo "Environment variables saved to .devcontainer/.env"

# Create mcp-workspace directory if it doesn't exist
if [ ! -d "../mcp-workspace" ]; then
    echo "Creating mcp-workspace directory..."
    mkdir -p ../mcp-workspace
fi

cd .devcontainer

# Build the base image first
echo "Building base image..."
docker-compose build base

# Then build the service containers with the build-only profile enabled
echo "Building service containers..."
docker-compose --profile build-only build typescript python texlive mcp

echo "Containers built with user: $LOCAL_USERNAME ($LOCAL_USER_UID:$LOCAL_USER_GID)"