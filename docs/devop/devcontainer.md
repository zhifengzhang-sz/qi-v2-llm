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

## Environment Setup

### Initial Setup

To set up the environment, run:

```bash
npm run setup
```

This script:
1. Captures local user information
2. Creates necessary configuration files
3. Builds the base container image
4. Builds all service containers (TypeScript, Python, TeXLive, and MCP)

### Directory Structure

The `.devcontainer` directory contains:
- `devcontainer.json`: Main VS Code DevContainer configuration
- `docker-compose.yml`: Container orchestration configuration
- `setup.sh`: Environment setup script
- Container-specific directories: `base`, `python`, `typescript`, `texlive`, `mcp`

## Common Issues and Troubleshooting

### Network Timeouts During Package Installation

**Issue**: Package installation (especially for Python) times out during container build.

**Solution**:
1. Increase timeout values in the Dockerfile:
   ```dockerfile
   RUN pip config set global.timeout 300 && \
       pip install --upgrade pip setuptools wheel
   ```
2. Use a closer mirror or proxy for package installation
3. Split large package installation steps into multiple smaller steps

### Docker Base Image Access Issues

**Issue**: Unable to access Ubuntu base image or Docker Hub.

**Solution**:
1. Check your network connection to Docker Hub
2. Use regional Docker mirrors (see `scripts/docker-china-mode.sh`)
3. Verify Docker daemon is running and accessible
4. Use a more stable base image version if needed

### Directory Permission Issues

**Issue**: Permission errors when accessing workspace directories.

**Solution**:
1. Make sure the `postCreateCommand` is correctly setting permissions:
   ```json
   "postCreateCommand": "sudo chown -R $(id -u):$(id -g) /workspace"
   ```
2. Check that user IDs in the container match your local user
3. Verify that `.devcontainer/.env` contains correct `LOCAL_USER_UID` and `LOCAL_USER_GID`

### Python Directory Structure Issues

**Issue**: Python modules aren't found or directory structure causes errors.

**Solution**:
1. Ensure all parent directories are created before attempting to create files:
   ```dockerfile
   RUN mkdir -p /workspace/mcp/server/src/models && \
       mkdir -p /workspace/mcp/server/src/data && \
       mkdir -p /workspace/mcp/server/src/utils && \
       mkdir -p /workspace/mcp/server/src/api
   ```
2. Use explicit individual `touch` commands for creating files
3. Check ownership of directories with `chown`

### Jupyter Notebook Integration

**Issue**: Jupyter notebooks aren't accessible or don't work correctly.

**Solution**:
1. Ensure the Jupyter extension is installed in VS Code
2. Verify that Jupyter packages are installed in the container
3. Use the correct Python kernel path in notebook settings
4. Check port forwarding (8888) is configured correctly in `docker-compose.yml`

## Custom Functions

The MCP environment includes several custom zsh functions to streamline development:

- `mcp-init`: Initialize a new MCP project with server and client
- `mcp-ts-init`: Initialize a time series research project
- `mcp-cursor-init`: Set up Cursor AI integration

Use these functions directly in the terminal after starting the MCP container.

## Environment Variables

Important environment variables used in the container setup:

- `LOCAL_USERNAME`: Your local username (default: vscode)
- `LOCAL_USER_UID`: Your local user ID (default: 1000)
- `LOCAL_USER_GID`: Your local group ID (default: 1000)
- `OPENAI_API_KEY`: Your OpenAI API key for Cursor integration (optional)

These are automatically captured and stored in `.devcontainer/.env` during setup.

## Rebuilding Containers

If you need to rebuild containers after changes, use:

```bash
cd .devcontainer
docker-compose build <service-name>
```

Replace `<service-name>` with `base`, `python`, `typescript`, `texlive`, or `mcp`.
