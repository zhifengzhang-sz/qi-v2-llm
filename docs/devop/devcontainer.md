# Multi-Language Development Environment with VS Code DevContainers

This document provides detailed information about the DevContainer setup for this multi-language development environment.

## Overview

Our DevContainer configuration creates isolated development environments for three distinct programming ecosystems:

- **TypeScript**: JavaScript/TypeScript development with Node.js
- **Python**: Python 3.10+ development with enhanced shell experience
- **TeXLive**: LaTeX document preparation

Each environment is containerized to provide consistent development experiences regardless of the host system.

## Configuration Details

### Root Configuration

The `.devcontainer/devcontainer.json` file defines the multi-container setup:

```jsonc
{
  "name": "Multi-Language Development Containers",
  "dockerComposeFile": "docker-compose.yml",
  "service": "typescript", // Default service
  "workspaceFolder": "/workspace",
  "updateRemoteUserUID": true,
  "settings": {
    "typescript.tsdk": "/usr/local/lib/node_modules/typescript/lib"
  },
  "extensions": [
    "ms-vscode.vscode-typescript-tslint-plugin",
    "ms-python.python",
    "James-Yu.latex-workshop"
  ]
}
```

### Docker Compose

The docker-compose.yml file orchestrates all three container environments:

```yaml
version: '3'

services:
  typescript:
    build:
      context: ./typescript
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ..:/workspace:cached
    working_dir: /workspace/typescript-workspace
    command: sleep infinity

  python:
    build: 
      context: ./python
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ..:/workspace:cached
    working_dir: /workspace/python-workspace
    network_mode: "host"
    command: sleep infinity

  texlive:
    build:
      context: ./texlive
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ..:/workspace:cached
    working_dir: /workspace/texlive-workspace
    command: sleep infinity
```

### Dynamic User Configuration

The setup.sh script dynamically captures the host user information:

```bash
#!/bin/bash

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
```

### Region-Specific Docker Configuration

Two utility scripts handle switching between global and regional Docker registry access:

- `docker-china-mode.sh`: Configures Docker to use Chinese registry mirrors
- `docker-global-mode.sh`: Resets Docker to use the default global registries

## Using the DevContainers

### Initial Setup

1. Run the setup script to capture your user information:
   ```bash
   npm run setup
   ```

2. If you're in a region with restricted Docker Hub access:
   ```bash
   npm run docker:china
   ```
   Otherwise, for global access:
   ```bash
   npm run docker:global
   ```

3. Open VS Code in the project directory:
   ```bash
   code .
   ```

4. Press F1 and select "Remote-Containers: Reopen in Container"

### Switching Between Environments

You can switch between development environments in VS Code:

1. Press F1 to open the Command Palette
2. Select "Remote-Containers: Open Folder in Container..."
3. Choose the appropriate workspace folder:
   - typescript-workspace for TypeScript development
   - python-workspace for Python development
   - texlive-workspace for LaTeX development

## Customization

### Adding Extensions

To add VS Code extensions to specific environments, modify the corresponding `devcontainer.json` file. For example:

```jsonc
"extensions": [
  "ms-python.python",
  "ms-toolsai.jupyter", 
  "ms-python.vscode-pylance"
]
```

### Modifying Dockerfiles

Each environment has its own Dockerfile that you can customize with additional packages or configurations.

### Shell Experience

All environments use Oh My Zsh with the "agnoster" theme and useful plugins:

- `zsh-autosuggestions`: Command suggestions based on history
- `zsh-syntax-highlighting`: Syntax highlighting for commands
- Environment-specific plugins (python, npm, etc.)

## Troubleshooting

### Docker Connectivity Issues

If you experience Docker Hub connectivity issues:

1. Check your network connectivity
2. Try switching between regional and global configurations
3. Use the built-in test-network function in containers

### File Permission Issues

If you encounter file permission problems, ensure:

1. The setup script has run successfully
2. User IDs match between host and container
3. Volume mounts are working correctly

For other issues, refer to the Docker and VS Code Remote-Containers documentation.
