# Quantum Intelligence (QI) - Multi-Language Development Environment

This repository contains a comprehensive multi-language development environment for Quantum Intelligence projects, featuring containerized environments for Python, TypeScript, LaTeX, and Model Context Protocol (MCP) development.

## Features

- **Multi-Container Development Environment:** Isolated development environments for different programming languages
- **VS Code Integration:** Optimized for development with Visual Studio Code and DevContainers
- **Pre-configured Tools:** Ready-to-use development tools and libraries for each language
- **MCP Support:** Built-in support for Model Context Protocol research and development
- **Time Series Analysis:** Tools for time series forecasting, analysis, and visualization

## Prerequisites

- Docker and Docker Compose
- Visual Studio Code with Remote Development extension
- Git

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/qi-v2-llm.git
   cd qi-v2-llm
   ```

2. Set up the development environment:
   ```bash
   npm run setup
   ```

3. Open the project in VS Code:
   ```bash
   code .
   ```

4. Use the "Reopen in Container" option when prompted by VS Code.

## AI Integration Setup

### Cursor with DeepSeek API

This environment supports using DeepSeek AI models with Cursor:

1. Set up your DeepSeek API key in the environment:
   ```bash
   npm run secrets:setup-deepseek
   ```

2. Rebuild containers if they're already running:
   ```bash
   npm run stop
   npm run start
   ```

3. Test your DeepSeek configuration:
   ```bash
   npm run deepseek:test
   ```

4. Configure Cursor to use DeepSeek:
   - Open Cursor Settings → Extensions → Cursor
   - Find "AI Model Configuration" section
   - Set Model: "deepseek-coder"
   - Set Base URL: "https://api.deepseek.com/v1"
   - Set API Key: your DeepSeek API key

For more details, see the [Secret Management Guide](docs/devop/secret-management.md).

### RAG and Agent Capabilities for Cryptocurrency Analysis

The MCP environment can be extended with Retrieval-Augmented Generation (RAG) and Agent capabilities for cryptocurrency market analysis:

1. Open the MCP container:
   ```bash
   npm run mcp
   ```

2. Run the installation script:
   ```bash
   /workspace/mcp/install-rag-agent.sh
   ```

3. After installation, set up the environment:
   ```bash
   source /workspace/mcp/setup-rag-agent-env.sh
   ```

4. Launch Jupyter Lab with the RAG and Agent examples:
   ```bash
   /workspace/mcp/launch-rag-agent.sh
   ```

For more details, see the [RAG and Agent Integration Guide](docs/guides/rag-agent-mcp-integration-guide.md).

## Container Environments

### MCP Container (Default)
The Model Context Protocol container combines Python and TypeScript development environments with specialized tools for LLM integration and time series analysis.

### Python Container
A Python-focused environment with scientific computing packages, Jupyter, and testing tools.

### TypeScript Container
A Node.js and TypeScript environment with modern JavaScript tooling.

### TeXLive Container
A LaTeX environment for document preparation with common LaTeX packages.

## Troubleshooting

### Network Issues During Setup
If you encounter network timeouts during setup:

- For Docker image access issues, check your network connection to Docker Hub
- For Python package installation failures, you can modify the timeout in the Dockerfile
- Use the provided scripts in `scripts/` directory to configure Docker and GitHub settings for your region

### Container Build Failures
If container building fails:

1. Check if the base image built successfully
2. Verify environment variables are correctly set in `.devcontainer/.env`
3. Ensure Docker has sufficient resources allocated (memory/CPU)
4. Try rebuilding individual containers:
   ```bash
   cd .devcontainer
   docker-compose build <container-name>
   ```

## Directory Structure

- `.devcontainer/`: Configuration for VS Code DevContainers
- `docs/`: Documentation and guides
- `mcp-workspace/`: Working directory for MCP development
- `python-workspace/`: Working directory for Python development
- `typescript-workspace/`: Working directory for TypeScript development
- `texlive-workspace/`: Working directory for LaTeX documents
- `scripts/`: Utility scripts for environment configuration

## License

[MIT License](LICENSE)
