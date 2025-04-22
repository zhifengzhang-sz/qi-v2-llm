# Multi-Language Development Containers for LLM

A comprehensive development environment supporting TypeScript, Python, and LaTeX using VS Code DevContainers. Designed for consistent development experiences across team members and different network environments.

## Features

- **Multiple Language Support**: TypeScript, Python, and LaTeX/TeXLive
- **Isolated Environments**: Consistent, containerized development setups
- **Network Flexibility**: Tools for switching between global and region-specific Docker registries
- **Enhanced Shell Experience**: Custom Oh My Zsh configuration with helpful plugins
- **Dynamic User Mapping**: Container users match your host system user

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
│   ├── devcontainer.json          # Root configuration
│   ├── docker-compose.yml         # Multi-container orchestration
│   ├── setup.sh                   # Setup script for user configuration
│   ├── python/                    # Python environment
│   ├── typescript/                # TypeScript environment 
│   └── texlive/                   # LaTeX environment
├── python-workspace/              # Python code
├── typescript-workspace/          # TypeScript code
├── texlive-workspace/             # LaTeX documents
└── docs/                          # Documentation
    └── devop/
        └── devcontainer.md        # DevContainer documentation
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.
