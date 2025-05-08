# Cursor + VS Code + DeepSeek Integration Guide

This guide provides step-by-step instructions for setting up and using Cursor with DeepSeek AI models in your development workflow.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Understanding Cursor vs VS Code](#understanding-cursor-vs-vs-code)
4. [Setting Up Your Environment](#setting-up-your-environment)
5. [Configuring DeepSeek in Cursor](#configuring-deepseek-in-cursor)
6. [Working with Cursor and Development Containers](#working-with-cursor-and-development-containers)
7. [Advanced Usage Scenarios](#advanced-usage-scenarios)
8. [Troubleshooting](#troubleshooting)

## Introduction

Cursor is an AI-powered code editor built on VS Code's codebase that enhances your development experience with intelligent code suggestions, natural language processing, and deep code understanding. By integrating Cursor with DeepSeek, you gain access to powerful AI capabilities while maintaining the familiar VS Code-like environment.

This guide will help you set up and use this powerful combination of tools within the Quantum Intelligence (QI) development environment.

## Prerequisites

Before you begin, ensure you have:

- [Cursor](https://cursor.sh/) installed on your system
- [Docker](https://www.docker.com/) and Docker Compose installed
- A DeepSeek account and API key ([Sign up here](https://platform.deepseek.com/))
- The QI development environment cloned from the repository

## Understanding Cursor vs VS Code

It's important to understand the relationship between Cursor and VS Code:

### What is Cursor?

- Cursor is a **standalone application** based on VS Code's codebase
- It's essentially a fork of VS Code with enhanced AI capabilities built directly into the editor
- Cursor provides access to multiple AI models including GPT-3.5, GPT-4, DeepSeek-R1, DeepSeek-V3, and others
- These capabilities are more powerful than what's possible with VS Code extensions alone

### Difference Between Cursor and the AI Cursor Extension

- The **AI Cursor extension** (`ktiays.aicursor`) included in our devcontainer is a simple VS Code extension with limited functionality
- This extension only offers basic GPT-3.5 and GPT-4 integration
- To access the full range of AI models, particularly DeepSeek models, you must use the **standalone Cursor application**

### Should I Use VS Code or Cursor?

For the QI project, we recommend:
- Use Cursor as your primary editor to access the full range of AI models
- VS Code is not required if you're using Cursor since Cursor includes all VS Code functionality
- Cursor fully supports devcontainers, extensions, and all other VS Code features

## Setting Up Your Environment

### 1. Configure Your Development Environment

First, set up the QI development environment:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/your-username/qi-v2-llm.git
cd qi-v2-llm

# Run the setup script
npm run setup
```

### 2. Set Up Your DeepSeek API Key

Configure your DeepSeek API key in the environment:

```bash
npm run secrets:setup-deepseek
```

This script will prompt you for your DeepSeek API key and securely add it to your `.env` file.

### 3. Build and Start the Containers

If the containers are not yet running:

```bash
npm run build
npm run start
```

If they're already running, restart them to apply the new configuration:

```bash
npm run stop
npm run start
```

### 4. Test Your DeepSeek Configuration

Verify that your DeepSeek API key is working correctly:

```bash
npm run deepseek:test
```

A successful test will show a response from the DeepSeek API. If you see an "Insufficient Balance" error, you may need to add credits to your DeepSeek account.

## Configuring DeepSeek in Cursor

### 1. Open Cursor Settings

- Open the standalone Cursor application
- Go to File > Preferences > Settings (or press `Ctrl+,`)
- Click on "Extensions" in the left sidebar
- Select "Cursor" from the extensions list

### 2. Configure AI Model Settings

Scroll down to find the "AI Model Configuration" section and configure DeepSeek:

- Under "Custom Model Configuration", select "DeepSeek" as the model provider
- Set the following configuration:
  - Model: `deepseek-coder` (or other DeepSeek models like `deepseek-r1` or `deepseek-v3`)
  - Base URL: `https://api.deepseek.com/v1`
  - API Key: Enter your DeepSeek API key

### 3. Save Your Configuration

Click "Save" to apply the changes. Cursor will now use DeepSeek as your AI model for code suggestions and completions.

## Working with Cursor and Development Containers

### 1. Opening Your Project in Cursor with Devcontainer

After configuring Cursor and DeepSeek, open your project in Cursor:

```bash
# On Windows, you can launch Cursor and use the "Open Folder" option
# Or use the cursor CLI if available:
cursor .
```

When prompted, select "Reopen in Container" to open the project in a devcontainer. Cursor fully supports devcontainers just like VS Code does.

### 2. Using Cursor with WSL (Windows Subsystem for Linux)

If you're using Windows with WSL:

1. Install Cursor on Windows (not inside WSL)
2. Open Cursor
3. Use the "Remote - WSL" extension (pre-installed in Cursor) to connect to your Ubuntu subsystem
4. Navigate to your project directory in the WSL environment
5. Cursor will detect the devcontainer configuration and prompt to reopen in the container

This approach gives you:
- Windows native UI performance with Cursor
- Linux development environment with all your project's configurations
- Full access to DeepSeek and other AI models

### 3. Cursor's AI Features

Cursor provides several AI-powered features:

- **AI Command Palette**: Press `Ctrl+K` (or `Cmd+K` on macOS) to open the AI command palette
- **Inline Code Suggestions**: As you type, Cursor will suggest code completions
- **Natural Language Commands**: Type comments like `// create a function that sorts an array` and Cursor will generate the code
- **Explanations**: Select code and use `Ctrl+Shift+E` to have Cursor explain it
- **Model Selection**: Click on the AI model name in the bottom right to switch between different models

### 4. Key Cursor Shortcuts

| Action | Shortcut |
|--------|----------|
| Accept AI suggestions | `Tab` |
| Open AI command palette | `Ctrl+K` (or `Cmd+K` on macOS) |
| Execute current line in terminal | `Ctrl+Enter` |
| Explain selected code | `Ctrl+Shift+E` |
| Chat with AI | `Alt+/` (or `Option+/` on macOS) |

## Advanced Usage Scenarios

### Working with Time Series Data

Cursor with DeepSeek is particularly useful for time series analysis tasks in the MCP environment:

1. Open a Jupyter notebook in the MCP workspace:
   ```bash
   npm run mcp
   cd /workspace/mcp/notebooks
   jupyter lab
   ```

2. Create a new notebook for time series analysis

3. Use natural language prompts with Cursor to generate code, for example:
   ```
   # Use Prophet to forecast the following time series data with weekly seasonality
   ```

4. Cursor will suggest code to implement the requested functionality

### Collaborative Coding

You can use Cursor's collaboration features to work with team members:

1. Click the "Share" button in Cursor to create a collaborative session
2. Share the link with collaborators
3. Work together on the same files in real-time
4. Use the chat feature to discuss code changes

## Troubleshooting

### Common Issues and Solutions

#### 1. DeepSeek API Key Not Working

If your DeepSeek API key is not working:

- Verify the key is correctly set in your `.env` file: `cat .devcontainer/.env`
- Ensure the containers have been restarted after setting the key
- Check your DeepSeek account balance at [platform.deepseek.com](https://platform.deepseek.com/)

#### 2. Cursor Not Using DeepSeek

If Cursor is not using the DeepSeek model:

- Verify the model configuration in Cursor settings
- Ensure you've saved the configuration changes
- Try restarting Cursor

#### 3. "VS Code Extension" vs Standalone Cursor Confusion

If you're only seeing GPT-3.5 and GPT-4 models:
- You might be using the VS Code AI Cursor extension (`ktiays.aicursor`) instead of the standalone Cursor application
- Close VS Code, download and install the full Cursor application from [cursor.sh](https://cursor.sh/)
- Open your project with the standalone Cursor application instead

#### 4. Network Issues in China

If you're experiencing network issues in China:

- Use the provided scripts to configure for China networks:
  ```bash
  npm run network:china
  ```
- This will set up Docker, npm, and pip to use China mirrors

### Getting Help

If you encounter issues not covered in this guide:

- Check the [DeepSeek documentation](https://platform.deepseek.com/docs)
- Visit the [Cursor support forum](https://cursor.sh/support)
- Consult the VS Code documentation for devcontainer issues

## Conclusion

You now have a powerful AI-enhanced development environment by using Cursor with DeepSeek models. This setup allows you to leverage the capabilities of DeepSeek's AI models directly in your development environment, accelerating your coding workflow and enhancing productivity.

Happy coding!