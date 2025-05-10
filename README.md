# Quantitative Investment (QI) - Multi-Language Development Environment

This repository contains a comprehensive multi-language development environment for Quantitative Investment projects, featuring containerized environments for Python, TypeScript, LaTeX, and Model Context Protocol (MCP) development.

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
   git clone https://github.com/zhifengzhang-sz/qi-v2-llm.git
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

## Development Routes

This project supports two distinct development routes, each with its own AI-enhanced workflow:

### Route 1: VS Code with Cline AI
- **Best for**: Developers who prefer VS Code's ecosystem with AI enhancements
- **Setup**: Install VS Code and the Cline AI extension
- **Integration**: Cline AI operates within VS Code and connects to the MCP server
- **GitHub Copilot**: Works alongside GitHub Copilot for enhanced coding assistance
- **Documentation**: See [Cline AI Integration Guides](docs/guides/cline/mcp.md) and the [Getting Started Tutorial](docs/guides/cline/getting-started.md)

### Route 2: Cursor (Standalone)  
- **Best for**: Developers who want the most advanced AI coding features
- **Setup**: Install Cursor directly (not as a VS Code extension)
- **Integration**: Cursor has built-in AI features plus MCP server connection
- **Documentation**: See [Cursor Integration Guides](docs/guides/cursor/mcp.md)

Choose the route that best fits your workflow preferences and requirements.

## AI Integration Setup

### Cursor with DeepSeek API (Route 2)

This environment supports using DeepSeek AI models with the standalone Cursor application:

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

For more details, see the [Secret Management Guide](docs/devop/secret-management.md) and [Cursor DeepSeek Integration Guide](docs/guides/cursor/deepseek.md).

### RAG and Agent Capabilities for Cryptocurrency Analysis

The MCP environment can be extended with Retrieval-Augmented Generation (RAG) and Agent capabilities for cryptocurrency market analysis (compatible with both development routes):

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

### Cline AI with MCP Integration (Route 1)

This environment supports integrating Cline AI with the Model Context Protocol (MCP) for enhanced capabilities when using VS Code:

1. Open the MCP container:
   ```bash
   npm run mcp
   ```

2. Set up the Cline-MCP integration:
   ```bash
   mcp-cline-init
   ```

3. Start the MCP server for Cline:
   ```bash
   cd cline-mcp && npm start
   ```

4. Configure Cline AI to use the MCP server:
   - Open VS Code Settings → Extensions → Cline
   - Enable "Custom MCP Server"
   - Set MCP Server URL to "http://localhost:3000"

This integration allows Cline AI to access your project's specialized tools and capabilities through the MCP framework.

#### Cline AI and GitHub Copilot Integration

Cline AI is designed to work alongside GitHub Copilot in VS Code, offering complementary AI assistance:

- **GitHub Copilot** provides inline code suggestions based on the global knowledge it was trained on
- **Cline AI with MCP** provides domain-specific suggestions based on your project's context and specialized tools
- Use both simultaneously: Copilot for general coding and Cline for specialized time series analysis and MCP tools

To get the most out of this integration:
1. Install both the Cline AI and GitHub Copilot extensions in VS Code
2. Configure Cline AI to use the MCP server as described above
3. Use Copilot for general coding tasks and inline suggestions
4. Use Cline AI for specialized tasks that utilize MCP's time series analysis capabilities

> **Note**: A comprehensive tutorial for Cline AI setup and usage is currently in development. Check the [Cline AI guides](docs/guides/cline/) directory for the most up-to-date documentation.

For more details, see the [Cline AI MCP Integration Guide](docs/guides/cline/mcp.md).

## Comparison: Cursor vs Cline AI

| Feature | Cursor (Route 2) | Cline AI with VS Code (Route 1) |
|---------|-----------------|--------------------------------|
| **Installation** | Standalone application | VS Code extension |
| **Interface** | Custom UI based on VS Code | Integrated into VS Code |
| **AI Models** | Direct access to DeepSeek, Qwen3, etc. | Connects via MCP server |
| **GitHub Copilot** | Built-in alternative to Copilot | Works alongside Copilot |
| **MCP Integration** | Built-in support | Requires configuration |
| **Workflow** | Complete AI-focused environment | Enhanced VS Code experience |
| **Documentation** | [Cursor Guides](docs/guides/cursor/) | [Cline Guides](docs/guides/cline/) |

Choose the option that best aligns with your preferred development environment and workflow.

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
  - `guides/cursor/`: Documentation for Cursor integration (Route 2)
  - `guides/cline/`: Documentation for Cline AI with VS Code (Route 1)
    - `getting-started.md`: Comprehensive tutorial for Cline AI (in development)
    - `mcp.md`: MCP integration guide
    - `deepseek.md`: DeepSeek model integration
    - `qwen3.md`: Qwen3 model integration
  - `devop/`: DevOps and environment setup guides
- `mcp-workspace/`: Working directory for MCP development
- `python-workspace/`: Working directory for Python development
- `typescript-workspace/`: Working directory for TypeScript development
- `texlive-workspace/`: Working directory for LaTeX documents
- `scripts/`: Utility scripts for environment configuration

## License

[MIT License](LICENSE)
