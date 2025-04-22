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

# Build the containers with these variables
cd .devcontainer && docker-compose build

echo "Containers built with user: $LOCAL_USERNAME ($LOCAL_USER_UID:$LOCAL_USER_GID)"
echo "Environment saved to .devcontainer/.env"