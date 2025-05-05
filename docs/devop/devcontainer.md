# Multi-Language Development Environment with VS Code DevContainers

This document provides detailed information about the DevContainer setup for this multi-language development environment.

## Overview

Our DevContainer configuration creates isolated development environments for four distinct programming ecosystems:

- **Base**: Ubuntu 24.10 with common user setup and Oh My Zsh configuration
- **TypeScript**: JavaScript/TypeScript development with Node.js
- **Python**: Python 3.10+ development with enhanced shell experience
- **TeXLive**: LaTeX document preparation
- **MCP**: Combined Model Context Protocol environment with both Python and TypeScript

Each environment is containerized to provide consistent development experiences regardless of the host system.

## Architecture

The environment uses a layered container structure:

```
┌─────────────────────────────────────────────┐
│                                             │
│            Base Image (Ubuntu 24.10)        │
│   Common User Setup, Oh My Zsh, Shell Tools │
│                                             │
└───────────┬───────────┬───────────┬─────────┘
            │           │           │
┌───────────▼─┐ ┌───────▼───┐ ┌─────▼─────┐ ┌─────────▼─────────┐
│             │ │           │ │           │ │                   │
│  Python     │ │ TypeScript│ │  TeXLive  │ │        MCP        │
│ Environment │ │Environment│ │Environment│ │Python + TypeScript │
│             │ │           │ │           │ │                   │
└─────────────┘ └───────────┘ └───────────┘ └───────────────────┘
```

This architecture ensures:
- **Consistency**: All environments share the same base setup
- **Efficiency**: Common components aren't duplicated
- **Flexibility**: Specialized environments focus only on what they need
- **Maintainability**: Updating shared components only requires changes to the base image

## Configuration Details

### Root Configuration

The `.devcontainer/devcontainer.json` file defines the multi-container setup and now defaults to the MCP environment:

```jsonc
{
  "name": "Multi-Language Development Containers",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mcp", // Default to MCP environment
  "workspaceFolder": "/workspace/mcp",
  
  // Let VS Code handle user mapping
  "updateRemoteUserUID": true,
  
  "customizations": {
    "vscode": {
      "settings": {
        // Python settings
        "python.defaultInterpreterPath": "/opt/venv/bin/python",
        
        // TypeScript settings
        "typescript.tsdk": "/usr/local/lib/node_modules/typescript/lib"
      },
      "extensions": [
        // Python extensions
        "ms-python.python",
        "ms-toolsai.jupyter",
        
        // TypeScript extensions
        "ms-vscode.vscode-typescript-tslint-plugin",
        "esben.prettier-vscode",
        
        // LaTeX extensions
        "James-Yu.latex-workshop",
        
        // General extensions
        "shd101wyy.markdown-preview-enhanced",
        "redhat.vscode-yaml",
        "ktiays.aicursor"
      ]
    }
  },
  "postCreateCommand": "sudo chown -R $(id -u):$(id -g) /workspace"
}
```

### Docker Compose

The docker-compose.yml file orchestrates all container environments, with the base image being built first:

```yaml
services:
  # Base image that other services depend on
  base:
    build:
      context: ./base
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    image: qi-v2-llm-base:latest
    # Base is just for building, not for direct use
    profiles: ["build-only"]

  typescript:
    depends_on:
      - base
    build:
      context: . 
      dockerfile: ./typescript/Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ../typescript-workspace:/workspace:cached
    working_dir: /workspace
    command: sleep infinity

  python:
    depends_on:
      - base
    build: 
      context: ./python
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ../python-workspace:/workspace:cached
    working_dir: /workspace
    network_mode: "host"
    command: sleep infinity

  texlive:
    depends_on:
      - base
    build:
      context: ./texlive
      dockerfile: Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ../texlive-workspace:/workspace:cached
    working_dir: /workspace
    command: sleep infinity

  # MCP environment for Model Context Protocol development
  mcp:
    depends_on:
      - base
    build:
      context: . 
      dockerfile: ./mcp/Dockerfile
      args:
        USERNAME: "${LOCAL_USERNAME:-vscode}"
        USER_UID: "${LOCAL_USER_UID:-1000}"
        USER_GID: "${LOCAL_USER_GID:-1000}"
    volumes:
      - ../mcp-workspace:/workspace/mcp:cached
    ports:
      - "8000:8000" # For FastAPI server
    working_dir: /workspace/mcp
    network_mode: "host"
    command: sleep infinity
```

### Dynamic User Configuration

The setup.sh script dynamically captures the host user information and now also ensures the MCP workspace directory exists:

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

# Then build the service containers
echo "Building service containers..."
docker-compose build

echo "Containers built with user: $LOCAL_USERNAME ($LOCAL_USER_UID:$LOCAL_USER_GID)"
```

### Shell Configuration

All environments use a consistent Oh My Zsh setup with the "gnzh" theme and helpful plugins:

- `zsh-autosuggestions`: Command suggestions based on history
- `zsh-syntax-highlighting`: Syntax highlighting for commands
- Environment-specific plugins (python, npm, git, etc.)

### MCP Development Environment

The MCP environment combines Python and TypeScript capabilities and provides a specialized setup for Model Context Protocol development:

- Python with FastAPI for server-side development
- TypeScript for client-side development
- Helpful `mcp-init` function to scaffold new MCP projects

## Using the DevContainers

### Initial Setup

1. Run the setup script to capture your user information and build containers:
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

4. Press F1 and select "Remote-Containers: Reopen in Container" (defaults to MCP)

### Switching Between Environments

You can switch between development environments in VS Code:

1. Press F1 to open the Command Palette
2. Select "Remote-Containers: Reopen Folder in Container..."
3. Choose the appropriate workspace folder:
   - mcp-workspace for combined Python and TypeScript development
   - typescript-workspace for TypeScript-only development
   - python-workspace for Python-only development
   - texlive-workspace for LaTeX document development

### Creating MCP Projects

In the MCP environment, you can quickly create a new project skeleton:

```bash
mcp-init
```

This creates:
- A Python FastAPI server with example endpoints
- A TypeScript client with connection code
- All necessary configuration files

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

### Modifying Environment Setup

Each environment has dedicated setup files that can be modified:
- `base/Dockerfile`: Common setup for all environments
- `python/python-setup.zsh`: Python-specific configuration
- `typescript/typescript-setup.zsh`: TypeScript-specific configuration
- `mcp/mcp-setup.zsh`: MCP-specific functions and settings

## Troubleshooting

### Docker Connectivity Issues

If you experience Docker Hub connectivity issues:

1. Check your network connectivity
2. Try switching between regional and global configurations:
   ```bash
   npm run network:china  # For China network
   npm run network:global # For global network
   ```
3. Use the built-in test-network function in containers:
   ```bash
   test-network
   ```

### File Permission Issues

If you encounter file permission problems, ensure:

1. The setup script has run successfully
2. User IDs match between host and container
3. Volume mounts are working correctly

For other issues, refer to the Docker and VS Code Remote-Containers documentation.
