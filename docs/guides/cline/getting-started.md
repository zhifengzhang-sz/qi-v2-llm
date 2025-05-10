# Getting Started with Cline AI in VS Code

This guide provides a comprehensive tutorial on setting up and using Cline AI with VS Code and GitHub Copilot for quantitative finance and time series analysis.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Working with GitHub Copilot](#working-with-github-copilot)
6. [MCP Integration](#mcp-integration)
7. [Example Workflows](#example-workflows)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Resources and Further Reading](#resources-and-further-reading)

## Introduction

Cline AI is a powerful VS Code extension that enhances your development workflow for specialized tasks, particularly in quantitative finance and time series analysis. This guide will help you set up and effectively use Cline AI alongside GitHub Copilot for maximum productivity.

### What is Cline AI?

Cline AI is an AI-powered coding assistant designed specifically for specialized domains like financial analysis and time series data processing. Unlike more general-purpose AI coding assistants, Cline AI:

- Connects to the Model Context Protocol (MCP) for domain-specific capabilities
- Understands financial models and time series analysis techniques
- Integrates with your project's specialized tools through the MCP server
- Works alongside GitHub Copilot to provide complementary assistance

## Prerequisites

Before you begin, ensure you have:

- VS Code installed (latest version recommended)
- A GitHub account with Copilot subscription (optional but recommended)
- The QI development environment set up (see the main README.md)
- Docker and Docker Compose installed
- Git configured on your system

### System Requirements

- **Operating System**: Windows 10/11, macOS 12+, or Linux
- **Memory**: At least 8GB RAM recommended
- **Disk Space**: At least 2GB of free disk space for the development environment
- **Network**: Stable internet connection for API access

## Installation

1. Install Cline AI extension:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Cline AI"
   - Click Install

2. Install GitHub Copilot (optional but recommended):
   - In VS Code Extensions, search for "GitHub Copilot"
   - Click Install
   - Sign in to your GitHub account when prompted

3. Install recommended additional extensions:
   - Python extension for VS Code
   - Jupyter extension
   - Docker extension
   - Git Graph
   - GitLens

4. Clone the QI repository if you haven't already:
   ```bash
   git clone https://github.com/zhifengzhang-sz/qi-v2-llm.git
   cd qi-v2-llm
   ```

5. Set up the development environment:
   ```bash
   npm run setup
   ```

## Configuration

### Basic Cline AI Setup

1. Open Cline AI settings:
   - Go to File > Preferences > Settings
   - Search for "Cline AI"
   - Configure basic settings:
     - Enable/disable auto-suggestions
     - Adjust response length
     - Set keybindings

### MCP Integration

For advanced features, configure Cline AI to work with the Model Context Protocol (MCP):

1. Set up the MCP environment:
   ```bash
   npm run mcp
   mcp-cline-init
   ```

2. Start the MCP server:
   ```bash
   cd cline-mcp && npm start
   ```

3. Configure Cline AI to use MCP:
   - Open VS Code Settings
   - Search for "Cline AI MCP"
   - Enable "Custom MCP Server"
   - Set the server URL to "http://localhost:3000"

### Advanced Configuration Options

#### Model Selection

Cline AI can be configured to use different AI models:

1. DeepSeek Model Configuration:
   - In VS Code settings, search for "Cline AI Models"
   - Select "DeepSeek" from the model dropdown
   - Enter your DeepSeek API key
   - Set the model name (e.g., "deepseek-coder")

2. Qwen3 Model Configuration:
   - Similar to DeepSeek setup, select "Qwen" as the model provider
   - Enter your Qwen API credentials
   - Select the appropriate model version

#### Customizing Response Behavior

Fine-tune how Cline AI responds to your queries:

- **Response Length**: Adjust the maximum tokens generated
- **Temperature**: Control creativity vs. determinism (0.0-1.0)
- **Context Window**: Set how much context is sent to the model
- **Code Focus**: Prioritize code generation over explanations

## Working with GitHub Copilot

Cline AI and GitHub Copilot can work together effectively:

### When to Use Each Tool

- **GitHub Copilot**: Best for general coding tasks, boilerplate code, and standard programming patterns
- **Cline AI**: Best for domain-specific tasks, particularly time series analysis and quantitative finance

### Switching Between Tools

1. For general coding tasks:
   - Let Copilot provide inline suggestions as you type
   - Accept suggestions with Tab key

2. For specialized tasks:
   - Use Cline AI commands (typically Ctrl+Shift+P and search for "Cline")
   - Leverage MCP-specific capabilities for time series analysis

### Combined Workflow Example

```python
# Let GitHub Copilot help with basic data loading
import pandas as pd
import numpy as np

# Use Cline AI for specialized time series analysis
# Cline command: "Analyze this financial time series for seasonality"
def analyze_seasonality(time_series_data):
    # Cline AI will generate specialized code here
    pass
```

### Key Differences Between Cline AI and GitHub Copilot

| Feature | GitHub Copilot | Cline AI |
|---------|---------------|----------|
| **Primary Focus** | General coding assistance | Domain-specific assistance |
| **Suggestion Style** | Inline completions | Command-driven responses |
| **Knowledge Base** | General coding patterns | Specialized financial models |
| **Integration** | Built into VS Code | Works with custom MCP tools |
| **Best For** | Everyday coding tasks | Complex financial algorithms |

### Keyboard Shortcuts

For efficient workflow, configure these recommended keyboard shortcuts:

1. GitHub Copilot:
   - Accept suggestion: `Tab`
   - Reject suggestion: `Esc`
   - Show next suggestion: `Alt+]`
   - Show previous suggestion: `Alt+[`

2. Cline AI:
   - Open command input: `Ctrl+Shift+C`
   - Execute selected code: `Ctrl+Enter`
   - Generate documentation: `Ctrl+Shift+D`

## Example Workflows

_Detailed example workflows will be added in a future update._

### Time Series Analysis Workflow

Here's a step-by-step example of using Cline AI for time series analysis:

1. **Data Preparation**:
   ```python
   # GitHub Copilot helps with basic setup
   import pandas as pd
   import numpy as np
   import matplotlib.pyplot as plt
   from datetime import datetime
   
   # Load cryptocurrency data
   btc_data = pd.read_csv('data/btc_price.csv')
   btc_data['date'] = pd.to_datetime(btc_data['date'])
   btc_data.set_index('date', inplace=True)
   ```

2. **Specialized Analysis** (use Cline AI):
   - Open Cline AI command panel (Ctrl+Shift+C)
   - Type prompt: "Analyze this Bitcoin price data for seasonality and trends using MCP tools"
   - Cline AI will generate specialized code like:
   ```python
   # MCP-powered time series decomposition
   from mcp.time_series import decompose, detect_anomalies, forecast
   
   # Perform decomposition
   components = decompose(btc_data['close'], method='STL', period=7)
   
   # Plot components
   fig, axes = plt.subplots(4, 1, figsize=(12, 10))
   components['observed'].plot(ax=axes[0], title='Observed')
   components['trend'].plot(ax=axes[1], title='Trend')
   components['seasonal'].plot(ax=axes[2], title='Seasonal')
   components['residual'].plot(ax=axes[3], title='Residual')
   plt.tight_layout()
   ```

3. **Forecast Generation**:
   - Use Cline AI to create forecasting models
   - Request: "Generate a 30-day forecast using the most appropriate model for this Bitcoin data"

### Financial Model Development

1. **Model Framework** (GitHub Copilot):
   - Basic class structure and data handling
   
2. **Mathematical Implementation** (Cline AI):
   - Complex financial calculations with specialized MCP tools
   
3. **Visualization and Analysis** (Combined approach):
   - Copilot for plotting boilerplate
   - Cline AI for specialized financial visualizations

## Troubleshooting

_Common issues and their solutions will be added in a future update._

### Common Issues

#### MCP Connection Problems

**Issue**: Cline AI cannot connect to the MCP server
**Solution**:
1. Verify the MCP server is running:
   ```bash
   cd cline-mcp
   npm start
   ```
2. Check that the server URL is correct in VS Code settings
3. Ensure no firewall is blocking the connection
4. Verify port 3000 is not being used by another application

#### Authentication Errors

**Issue**: Authentication errors with AI models
**Solution**:
1. Verify your API keys are correctly entered in settings
2. Check that your API key has not expired
3. Ensure you have sufficient credits/quota for the selected model
4. Try using a different model if persistent issues occur

#### Performance Issues

**Issue**: Slow response times from Cline AI
**Solution**:
1. Reduce the amount of context being sent to the model
2. Close unused VS Code windows and extensions
3. Increase VS Code memory allocation if possible
4. Try a lighter-weight model if using a resource-intensive one

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [GitHub Issues](https://github.com/zhifengzhang-sz/qi-v2-llm/issues) for similar problems
2. Join the community discussion on our Discord channel
3. Contact the development team via email at support@example.com

## Best Practices

### Effective Prompting

For best results with Cline AI:

1. **Be specific**: "Calculate the Sharpe ratio for this portfolio using annualized returns"
2. **Provide context**: Include relevant information about your data and requirements
3. **Break down complex tasks**: Request one operation at a time for complex workflows
4. **Leverage MCP tools**: Explicitly mention MCP tools when applicable

### Secure API Key Management

Always keep your API keys secure:

1. Store keys in environment variables when possible
2. Never commit API keys to version control
3. Use the built-in secret management system:
   ```bash
   npm run secrets:setup
   ```

### Version Control Integration

When using Git with Cline AI:

1. Let Cline AI help generate meaningful commit messages
2. Use Cline AI to explain complex code before committing
3. Have Cline AI review code changes for potential issues

## Resources and Further Reading

### Documentation

- [Cline AI MCP Integration Guide](mcp.md)
- [Cline AI DeepSeek Integration](deepseek.md)
- [Cline AI Qwen3 Integration](qwen3.md)
- [Time Series Analysis with Cline AI](mcp.time-series.md)

### External Resources

- [VS Code Documentation](https://code.visualstudio.com/docs)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Model Context Protocol Specification](https://github.com/zhifengzhang-sz/qi-v2-llm/docs/mcp-spec.md)
- [Pandas Time Series Documentation](https://pandas.pydata.org/pandas-docs/stable/user_guide/timeseries.html)

### Community

- [QI Project GitHub Repository](https://github.com/zhifengzhang-sz/qi-v2-llm)
- [Community Forum](https://example.com/forum)
- [Cline AI User Group](https://example.com/user-group)

---

**Last Updated**: May 10, 2025  
**Version**: 1.0.0

This guide is actively maintained. Please check back regularly for updates and new features.
