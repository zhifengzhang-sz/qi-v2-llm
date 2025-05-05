# Multi-Language Development Containers for LLM

A comprehensive development environment supporting TypeScript, Python, and LaTeX using VS Code DevContainers. Designed for consistent development experiences across team members and different network environments.

## Features

- **Multiple Language Support**: TypeScript, Python, LaTeX/TeXLive, and combined MCP environment
- **Layered Architecture**: Common base image with specialized development environments
- **Isolated Environments**: Consistent, containerized development setups
- **Network Flexibility**: Tools for switching between global and region-specific Docker registries
- **Enhanced Shell Experience**: Custom Oh My Zsh configuration with helpful plugins
- **Dynamic User Mapping**: Container users match your host system user
- **MCP Development**: Combined Python and TypeScript for Model Context Protocol development

## Quick Start

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/qi-v2-llm.git
   cd qi-v2-llm
   ```

2. Install npm dependencies:
   ```bash
   npm install
   ```

3. Run the setup script:
   ```bash
   npm run setup
   ```

4. Open VS Code:
   ```bash
   code .
   ```

5. Use Command Palette (F1) → "Remote-Containers: Reopen in Container"

### Environment Selection

By default, you'll open in the MCP (Model Context Protocol) environment. To use a specific environment:

1. Open Command Palette (F1)
2. Select "Remote-Containers: Reopen Folder in Container"
3. Choose from:
   - MCP (default): Combined Python and TypeScript
   - Python: Python development
   - TypeScript: TypeScript/JavaScript development
   - TeXLive: LaTeX document preparation

### MCP Development

When in the MCP environment, you can create a new project skeleton with:

```bash
mcp-init
```

This creates a FastAPI Python server and TypeScript client with example code.

### Region-Specific Configuration

For users in regions with network restrictions:

```bash
# Enable region-specific Docker mirrors
npm run docker:china

# Switch back to global configuration
npm run docker:global
```

## Project Structure

```
qi-v2-llm/
├── .devcontainer/                 # DevContainer configurations
│   ├── base/                      # Base image with common setup
│   ├── python/                    # Python environment
│   ├── typescript/                # TypeScript environment 
│   ├── texlive/                   # LaTeX environment
│   ├── mcp/                       # Model Context Protocol environment
│   ├── devcontainer.json          # Root configuration
│   ├── docker-compose.yml         # Multi-container orchestration
│   └── setup.sh                   # Setup script for user configuration
├── python-workspace/              # Python code
├── typescript-workspace/          # TypeScript code
├── texlive-workspace/             # LaTeX documents
├── mcp-workspace/                 # MCP (Python+TypeScript) code
├── scripts/                       # Network and environment setup scripts
└── docs/                          # Documentation
    └── devop/                     # DevOps documentation
```

## Architecture

The environment uses a layered container structure:

1. **Base image**: Ubuntu 24.10 with user setup and Oh My Zsh configuration
2. **Specialized images**: Python, TypeScript, TeXLive, and MCP (combines Python and TypeScript)

This approach ensures consistent user experience while minimizing duplication.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
