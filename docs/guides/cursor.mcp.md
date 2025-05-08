# Comprehensive Guide: Cursor + VS Code + MCP for Time Series Analysis

## Part 1: Getting Started with Cursor

### What is Cursor?
Cursor is an AI-powered code editor built on top of VS Code that enhances coding productivity through intelligent suggestions, natural language editing, and deep codebase understanding.

### Installing Cursor
1. Download Cursor from the official website (https://cursor.sh/)
2. Install for your operating system (Windows, macOS, or Linux)
3. Launch Cursor after installation

### Basic Cursor Usage
1. **AI Command Palette**: Press `Ctrl+K` (or `Cmd+K` on macOS) to open the AI command palette
2. **Inline Code Suggestions**: As you type, Cursor will suggest code completions
3. **Natural Language Commands**: Type comments like "// create a function that sorts an array" and Cursor will generate the code
4. **Explanations**: Select code and use `Ctrl+Shift+E` to have Cursor explain it

### Key Cursor Shortcuts
- `Tab`: Accept AI suggestions
- `Ctrl+K`: Open AI command palette (or `Cmd+K` on macOS)
- `Ctrl+Enter`: Execute current line in terminal
- `Ctrl+Shift+E`: Explain selected code

### Configuring Cursor to Use Alternative Models

Cursor supports different LLM backends to power its AI features. Here's how to configure it to use alternative models like DeepSeek R1:

1. **Open Cursor Settings**:
   - Go to File > Preferences > Settings (or press `Ctrl+,`)
   - Click on "Extensions" in the left sidebar
   - Select "Cursor" from the extensions list

2. **Configure Model Settings**:
   - Scroll down to find "AI Model Configuration" section
   - You can select from built-in models or configure custom models

3. **Setting Up DeepSeek R1**:
   - Click on "Custom Model Configuration"
   - Select "DeepSeek" as the model provider
   - For DeepSeek R1, use these settings:
     - Model: "deepseek-coder-7b-instruct"
     - Base URL: "https://api.deepseek.com/v1" (or your custom API endpoint)
     - API Key: Enter your DeepSeek API key
   - Click "Save" to apply the changes

4. **Verifying Model Configuration**:
   - Open the AI Command Palette (Ctrl+K)
   - Type: "What model are you using?"
   - The response should confirm your selected model

5. **Switching Between Models**:
   - You can quickly switch between configured models using the model selector dropdown in the bottom status bar
   - Alternatively, use Settings to change your default model

### Example: Using Cursor for Basic Coding
1. Create a new file named `example.py`
2. Type a comment: `# Create a function to calculate Fibonacci numbers`
3. Press `Ctrl+K` and watch Cursor generate the function
4. Modify by adding another comment: `# Add memoization to improve performance`
5. See how Cursor enhances the code intelligently

## Part 2: Integrating Cursor with VS Code

### Setting Up the Integration
1. Ensure VS Code is installed on your system
2. In Cursor, go to Settings > Extensions
3. You'll notice Cursor supports VS Code extensions natively
4. Install the key extensions:
   - Python extension for VS Code
   - Jupyter extension
   - Git extensions
   - Any other extensions you commonly use in VS Code

### Synchronizing Settings
1. Export VS Code settings:
   - In VS Code: File > Preferences > Settings
   - Click the "Open Settings (JSON)" button in the top right
   - Copy the JSON content
2. Import to Cursor:
   - In Cursor: File > Preferences > Settings
   - Paste your VS Code settings

### Working with Projects
1. Open existing VS Code projects in Cursor:
   - File > Open Folder
   - Navigate to your VS Code project folder
2. Use Cursor's AI features while maintaining VS Code's familiar environment
3. Version control works the same way as in VS Code

### Collaborative Features
1. Use Cursor's "Share" button to collaborate in real-time
2. Share terminal sessions and file edits
3. Discuss code with collaborators using Cursor's chat feature

### Example Workflow: Refactoring Code
1. Open a complex VS Code project in Cursor
2. Select a function that needs optimization
3. Use Cursor's AI command: "Refactor this function to improve performance"
4. Review the suggested changes and apply them
5. Commit changes using Git integration

## Part 3: Cursor + VS Code + MCP for Time Series Analysis

### Setting Up the MCP Environment
1. Ensure your MCP container is running:
   ```bash
   docker-compose up mcp
   ```
2. Connect Cursor to the MCP container:
   - Use VS Code's Remote Containers extension integration
   - Select "Attach to Running Container"
   - Choose the MCP container

### Time Series Analysis Project Setup
1. Create a new project directory in the MCP workspace:
   ```bash
   mkdir -p /workspace/mcp/time-series-analysis
   cd /workspace/mcp/time-series-analysis
   ```
2. Initialize a new Jupyter notebook:
   ```bash
   jupyter notebook time_series_analysis.ipynb
   ```

### Loading and Exploring Time Series Data
1. Create code cells for data loading:
   ```python
   import pandas as pd
   import numpy as np
   import matplotlib.pyplot as plt
   import seaborn as sns
   from statsmodels.tsa.seasonal import seasonal_decompose
   from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
   
   # Load example time series data
   # Use Cursor to help with data loading by typing:
   # "Load example time series data from pandas"
   ```
2. Use Cursor to generate data visualization code:
   - Type a comment: `# Create time series visualization with trend, seasonality, and residuals`
   - Let Cursor generate the appropriate code

### Advanced Time Series Modeling
1. Use Cursor to help implement ARIMA models:
   ```python
   # Implement ARIMA model for time series forecasting
   ```
2. Leverage Cursor for complex statistical methods:
   ```python
   # Implement Prophet model for time series with multiple seasonality patterns
   ```
3. Evaluate and compare different models using Cursor-generated code

### MCP Integration for Enhanced Analysis
1. Connect to MCP APIs for additional data sources
2. Use MCP's specialized time series functions:
   ```python
   # Import MCP time series utilities
   from mcp.utils.time_series import decompose_advanced, forecast_with_confidence
   ```
3. Leverage pre-trained models available in the MCP environment

### Real-time Collaborative Analysis
1. Share your notebook via Cursor's collaboration features
2. Work simultaneously with team members on different sections
3. Use Cursor's AI to explain complex time series concepts to collaborators

### Deploying Time Series Models
1. Use Cursor to help create deployment code:
   ```python
   # Create FastAPI endpoint to serve time series predictions
   ```
2. Test the API using Cursor-generated test scripts
3. Document the model and API using Cursor's documentation generation

### Example End-to-End Project
A complete time series analysis project might include:
1. Data loading and cleaning
2. Exploratory data analysis and visualization
3. Time series decomposition and feature engineering
4. Model selection and training
5. Model evaluation and interpretation
6. Deployment as a prediction service
7. Documentation and reporting

Throughout each step, Cursor can provide intelligent assistance, generate boilerplate code, help debug issues, and explain complex statistical concepts.