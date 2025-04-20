# Multi-Language Development Environment with VS Code Devcontainers

This repository contains a development environment setup using VS Code's devcontainers feature, allowing you to work with multiple programming languages in isolated environments.

## Overview

The setup includes separate development environments for:
- **TypeScript**: For JavaScript/TypeScript development
- **Python**: For Python development
- **TeXLive**: For LaTeX document preparation

Each environment is containerized, allowing for consistent development experiences across team members without conflicting dependencies.

## Directory Structure

```
multi-lang-devcontainers/
├── .devcontainer/                 # Devcontainer configurations
│   ├── devcontainer.json          # Root devcontainer config
│   ├── docker-compose.yml         # Orchestration for all containers
│   ├── typescript/                # TypeScript container config
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   ├── python/                    # Python container config
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   └── texlive/                   # TeXLive container config
│       ├── Dockerfile
│       └── devcontainer.json
├── typescript-workspace/          # TypeScript project files
├── python-workspace/              # Python project files
├── texlive-workspace/             # LaTeX documents
└── README.md                      # Project documentation
```

## Setup Instructions

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) installed on your system
- [Visual Studio Code](https://code.visualstudio.com/) with the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension installed

### Opening a Specific Environment

1. Open VS Code
2. Press F1 and select **Remote-Containers: Open Folder in Container...**
3. Select one of the following directories:
   - typescript-workspace for TypeScript development
   - python-workspace for Python development
   - texlive-workspace for LaTeX development

VS Code will automatically build and connect to the appropriate container for the selected workspace.

## Container Configurations

### TypeScript Container

```json
// .devcontainer/typescript/devcontainer.json
{
  "name": "TypeScript Development",
  "dockerFile": "Dockerfile",
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-typescript-next"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode"
      }
    }
  },
  "forwardPorts": [3000],
  "postCreateCommand": "npm install",
  "remoteUser": "node"
}
```

```dockerfile
# .devcontainer/typescript/Dockerfile
FROM node:18

# Install essential tools
RUN apt-get update && apt-get -y install git curl

# Setup non-root user (optional)
ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

WORKDIR /workspaces

# Default command
CMD ["bash"]
```

### Python Container

```json
// .devcontainer/python/devcontainer.json
{
  "name": "Python Development",
  "dockerFile": "Dockerfile",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "njpwerner.autodocstring"
      ],
      "settings": {
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "python.formatting.provider": "black"
      }
    }
  },
  "postCreateCommand": "pip install -r requirements.txt",
  "remoteUser": "vscode"
}
```

```dockerfile
# .devcontainer/python/Dockerfile
FROM python:3.10-slim

# Install packages and Python tools
RUN apt-get update && apt-get -y install git

# Install common Python packages
RUN pip install --no-cache-dir pytest black pylint

# Setup non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /workspaces

# Default command
CMD ["bash"]
```

### TeXLive Container

```json
// .devcontainer/texlive/devcontainer.json
{
  "name": "TeXLive Development",
  "dockerFile": "Dockerfile",
  "customizations": {
    "vscode": {
      "extensions": [
        "james-yu.latex-workshop",
        "valentjn.vscode-ltex"
      ],
      "settings": {
        "latex-workshop.latex.autoBuild.run": "onSave",
        "latex-workshop.view.pdf.viewer": "tab"
      }
    }
  },
  "remoteUser": "vscode"
}
```

```dockerfile
# .devcontainer/texlive/Dockerfile
FROM ubuntu:22.04

# Install TeXLive and tools
RUN apt-get update && apt-get -y install \
    texlive-full \
    latexmk \
    git

# Setup non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /workspaces

# Default command
CMD ["bash"]
```

### Root Docker Compose

```yaml
# .devcontainer/docker-compose.yml
version: '3'
services:
  typescript:
    build:
      context: ./typescript
      dockerfile: Dockerfile
    volumes:
      - ..:/workspaces:cached
    command: sleep infinity

  python:
    build: 
      context: ./python
      dockerfile: Dockerfile
    volumes:
      - ..:/workspaces:cached
    command: sleep infinity

  texlive:
    build:
      context: ./texlive
      dockerfile: Dockerfile
    volumes:
      - ..:/workspaces:cached
    command: sleep infinity
```

## Usage Tips

### Switching Between Containers

To switch between development environments:

1. Close VS Code
2. Reopen VS Code and select a different workspace folder
3. VS Code will connect to the appropriate container

Alternatively, you can use the **Remote-Containers: Reopen in Container** command from the command palette (F1) to select a different container configuration.

### Shared Volumes

All containers mount the project directory as a volume, allowing you to:
- Access files across environments
- Persist changes when containers are rebuilt
- Share configuration files as needed

### Customizing Environments

To modify a container configuration:
1. Edit the appropriate Dockerfile or devcontainer.json file
2. Rebuild the container using the **Remote-Containers: Rebuild Container** command

## Troubleshooting

- **Container Build Issues**: Check Docker logs for detailed error messages
- **Extension Problems**: Verify that the specified extensions in each devcontainer.json file are available in the VS Code marketplace
- **Performance Issues**: Adjust the volume mount settings in docker-compose.yml for better filesystem performance

## Resources

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)
- [Advanced Container Configuration](https://code.visualstudio.com/docs/remote/devcontainerjson-reference)