# Cursor + VS Code + Model Context Protocol (MCP) Integration Guide

This tutorial provides a comprehensive guide to setting up and using the Model Context Protocol (MCP) development environment with Cursor and VS Code for time series analysis and AI-enhanced development.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Setting Up Your MCP Environment](#setting-up-your-mcp-environment)
4. [MCP Development with Cursor and VS Code](#mcp-development-with-cursor-and-vs-code)
5. [Time Series Analysis with MCP](#time-series-analysis-with-mcp)
6. [Practical Examples](#practical-examples)
7. [Advanced Workflows](#advanced-workflows)
8. [Troubleshooting](#troubleshooting)
9. [Conclusion](#conclusion)
10. [Additional Resources](#additional-resources)

## Introduction

The Model Context Protocol (MCP) provides a standardized interface for integrating AI models with time series data and analysis. When combined with Cursor's AI-assisted coding capabilities and VS Code's robust development environment, MCP becomes a powerful framework for developing time series models and AI applications.

This guide explains how to set up, configure, and effectively use these tools together to accelerate your development workflow.

## Prerequisites

Before you begin, ensure you have:

- [Cursor](https://cursor.sh/) installed on your system
- [Visual Studio Code](https://code.visualstudio.com/) with Remote Containers extension
- [Docker](https://www.docker.com/) and Docker Compose
- Git
- The QI development environment cloned from the repository

## Setting Up Your MCP Environment

### 1. Initial Setup

First, configure your development environment:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/zhifengzhang-sz/qi-v2-llm.git
cd qi-v2-llm

# Run the setup script
npm run setup
```

### 2. Configure AI Integration (Optional)

If you want to use DeepSeek or another AI provider with Cursor, set up your API key:

```bash
npm run secrets:setup-deepseek
```

See the [Cursor + VS Code + DeepSeek Integration Guide](./cursor-vscode-deepseek-guide.md) for detailed instructions on AI provider setup.

### 3. Build and Start the MCP Container

Start the MCP development container:

```bash
npm run build
npm run start
```

### 4. Open the Project in VS Code with Devcontainer

Launch VS Code and open the project:

```bash
code .
```

When prompted, select "Reopen in Container" to open the project in the MCP devcontainer environment.

## MCP Development with Cursor and VS Code

### MCP Workspace Structure

The MCP environment is organized as follows:

```
mcp-workspace/
├── client/                 # Client-side code for MCP integrations
│   └── src/                # TypeScript/JavaScript client source
├── server/                 # Server-side code for MCP
│   ├── src/
│   │   ├── api/            # API endpoints
│   │   ├── models/         # Model definitions and implementations
│   │   ├── data/           # Data processing utilities
│   │   └── utils/          # Helper utilities
│   └── tests/              # Server tests
├── notebooks/              # Jupyter notebooks for analysis and examples
│   └── time-series/        # Time series-specific notebooks
│       └── cursor_vscode_mcp_tutorial.ipynb
└── data/                   # Data storage directory
    ├── raw/                # Raw input data
    └── processed/          # Processed data ready for modeling
```

### Using Cursor with MCP

Cursor enhances your MCP development by providing AI-assisted coding. Here's how to use it effectively:

1. **Natural Language Prompts**: Use clear, descriptive comments to generate MCP-specific code. For example:
   ```python
   # Create a function to preprocess time series data by removing outliers and normalizing
   ```

2. **MCP Implementation Help**: Ask Cursor to help with implementing MCP interfaces:
   ```typescript
   // Implement the MCP context provider interface for time series data
   ```

3. **Code Explanation**: Select complex MCP code and press `Ctrl+Shift+E` to have Cursor explain it

### Recommended VS Code Extensions for MCP

The MCP devcontainer comes preconfigured with these essential extensions:

1. **Python and Jupyter**: For data analysis and modeling
2. **TypeScript/JavaScript**: For client development
3. **AI/Cursor Integration**: For AI-assisted development
4. **Time Series Visualization**: For data exploration

## Time Series Analysis with MCP

### Setting Up a Time Series Project

1. Navigate to your notebooks directory:
   ```bash
   npm run mcp
   cd /workspace/mcp/notebooks/time-series
   ```

2. Start a Jupyter Lab session:
   ```bash
   jupyter lab
   ```

3. Create a new notebook or open an existing one like `cursor_vscode_mcp_tutorial.ipynb`

### MCP Time Series Workflow

A typical MCP time series analysis workflow consists of:

1. **Data Loading**: Import and prepare your time series data
   ```python
   import pandas as pd
   import numpy as np
   from mcp.utils.data import load_time_series
   
   # Load data from a CSV file
   data = load_time_series('path/to/data.csv', date_column='timestamp')
   ```

2. **Exploration and Visualization**: Understand your data
   ```python
   import matplotlib.pyplot as plt
   from mcp.utils.visualization import plot_time_series_components
   
   # Visualize the time series data
   plot_time_series_components(data)
   
   # Check for seasonality, trend, and stationarity
   from mcp.analysis.decomposition import decompose_time_series
   decomposition = decompose_time_series(data['value'])
   decomposition.plot()
   plt.show()
   ```

3. **Feature Engineering**: Create relevant features for time series modeling
   ```python
   from mcp.utils.features import create_time_features
   
   # Add time-based features (day of week, month, etc.)
   data_with_features = create_time_features(data)
   
   # Create lag features
   from mcp.utils.features import create_lag_features
   data_with_lags = create_lag_features(data_with_features, lags=[1, 7, 30])
   ```

4. **Model Training**: Train a time series model with MCP context
   ```python
   from mcp.models.time_series import TimeSeriesModel
   from mcp.context import MCPContext
   
   # Create an MCP context
   context = MCPContext()
   
   # Train a time series model
   model = TimeSeriesModel(context=context)
   model.fit(data_with_lags, target_column='value')
   ```

5. **Evaluation and Prediction**: Assess and use your model
   ```python
   # Evaluate model performance
   from mcp.utils.evaluation import evaluate_time_series_model
   metrics = evaluate_time_series_model(model, data_with_lags, 'value')
   print(metrics)
   
   # Make predictions
   future_periods = 30
   predictions = model.predict(future_periods)
   
   # Visualize predictions
   from mcp.utils.visualization import plot_predictions
   plot_predictions(data['value'], predictions)
   ```

### Integrating RAG with Time Series Analysis

MCP supports Retrieval-Augmented Generation (RAG) to enhance time series analysis:

1. **Set up the RAG Agent**:
   ```bash
   cd /workspace
   ./install-rag-agent.sh
   ```

2. **Initialize RAG in your notebook**:
   ```python
   from mcp.rag import RAGAgent
   
   # Initialize RAG agent with time series knowledge base
   rag_agent = RAGAgent(knowledge_base='time_series')
   
   # Ask the RAG agent for analysis suggestions
   suggestions = rag_agent.query("What techniques should I use for this financial time series data?")
   print(suggestions)
   ```

3. **Using RAG for model selection**:
   ```python
   # Get model recommendations based on your data characteristics
   data_description = {
       "frequency": "daily",
       "seasonality": "weekly",
       "trend": "upward",
       "volatility": "high"
   }
   
   model_recommendations = rag_agent.recommend_models(data_description)
   print(model_recommendations)
   ```

## Practical Examples

### Example 1: Stock Price Prediction

```python
# Import necessary libraries
import pandas as pd
import numpy as np
from mcp.utils.data import load_stock_data
from mcp.models.time_series import LSTM
from mcp.context import MCPContext

# Load stock data
stock_data = load_stock_data('AAPL', start_date='2020-01-01')

# Prepare data for LSTM
from mcp.utils.preprocessing import prepare_for_lstm
X_train, y_train, X_test, y_test = prepare_for_lstm(
    stock_data, 
    target_column='close', 
    sequence_length=10,
    test_size=0.2
)

# Create MCP context
context = MCPContext()

# Initialize and train LSTM model
lstm_model = LSTM(context=context, units=50, dropout=0.2)
history = lstm_model.fit(
    X_train, y_train,
    validation_data=(X_test, y_test),
    epochs=50,
    batch_size=32
)

# Make predictions
predictions = lstm_model.predict(X_test)

# Visualize results
from mcp.utils.visualization import plot_stock_predictions
plot_stock_predictions(stock_data, predictions, test_size=0.2)
```

### Example 2: Energy Consumption Forecasting

```python
# Import necessary libraries
import pandas as pd
from mcp.utils.data import load_energy_data
from mcp.models.time_series import Prophet
from mcp.context import MCPContext

# Load energy consumption data
energy_data = load_energy_data('path/to/energy_data.csv')

# Prepare data for Prophet
from mcp.utils.preprocessing import prepare_for_prophet
prophet_data = prepare_for_prophet(energy_data, 
                                  date_column='timestamp', 
                                  target_column='consumption')

# Create MCP context
context = MCPContext()

# Initialize and train Prophet model
prophet_model = Prophet(context=context, 
                        yearly_seasonality=True, 
                        weekly_seasonality=True, 
                        daily_seasonality=True)
prophet_model.fit(prophet_data)

# Generate future dataframe and make predictions
future = prophet_model.make_future_dataframe(periods=30)
forecast = prophet_model.predict(future)

# Visualize forecast
prophet_model.plot(forecast)
prophet_model.plot_components(forecast)
```

## Advanced Workflows

### Integrating Multiple Data Sources

MCP supports seamless integration of multiple data sources:

```python
from mcp.utils.data import DataIntegrator

# Define data sources
sources = [
    {"type": "csv", "path": "data/time_series1.csv"},
    {"type": "api", "url": "https://api.example.com/data", "api_key": "YOUR_KEY"},
    {"type": "database", "connection_string": "postgresql://user:password@localhost/dbname"}
]

# Initialize integrator
integrator = DataIntegrator(context=context)

# Load and merge data
merged_data = integrator.integrate(sources, on='timestamp', how='outer')
```

### Automated Model Selection and Hyperparameter Tuning

MCP provides tools for automatic model selection:

```python
from mcp.auto.model_selection import AutoTimeSeriesModeler

# Initialize auto-modeler
auto_modeler = AutoTimeSeriesModeler(context=context)

# Fit multiple models and find the best one
best_model = auto_modeler.find_best_model(
    data, 
    target_column='value',
    models=['arima', 'prophet', 'lstm', 'xgboost'],
    metric='rmse'
)

# Get model performance comparison
comparison = auto_modeler.compare_models()
comparison.plot()
```

### Custom MCP Extensions

You can extend MCP functionality for specialized time series tasks:

```python
from mcp.extensions import MCPExtension
from mcp.context import MCPContext

class CustomTimeSeriesExtension(MCPExtension):
    def __init__(self, context: MCPContext):
        super().__init__(context)
        
    def specialized_analysis(self, data):
        # Implement custom analysis logic
        pass
        
    def register(self):
        # Register extension with MCP
        self.context.register_extension('custom_ts', self)
        
# Create and register extension
context = MCPContext()
extension = CustomTimeSeriesExtension(context)
extension.register()

# Use extension
result = context.extensions.custom_ts.specialized_analysis(data)
```

## Troubleshooting

### Common Issues and Solutions

1. **MCP Container Not Starting**
   - Check if Docker is running
   - Ensure ports are not already in use
   - Verify that the Docker daemon has sufficient resources

2. **Model Training Errors**
   - Check data format and ensure no missing values
   - Verify that features are properly scaled
   - Increase memory allocation if dealing with large datasets

3. **RAG Agent Issues**
   - Ensure the agent is properly installed
   - Check connectivity to knowledge bases
   - Verify API keys and authentication

### Getting Help

If you encounter problems:

1. Check the logs:
   ```bash
   npm run logs
   ```

2. Visit the MCP documentation at [https://mcp-docs.example.com](https://mcp-docs.example.com)

3. Join the community Discord server for real-time assistance

4. File an issue on the GitHub repository

## Conclusion

By combining Cursor, VS Code, and the Model Context Protocol, you have a powerful environment for time series analysis and AI-enhanced development. This integration streamlines the entire workflow from data preparation to model deployment, allowing you to focus on solving domain-specific problems rather than dealing with tool configuration and integration issues.

As you continue to work with this environment, explore the advanced features and customization options to tailor it to your specific needs.

## Additional Resources

- [MCP Documentation](https://mcp-docs.example.com)
- [Cursor AI Documentation](https://docs.cursor.sh)
- [VS Code DevContainers Guide](https://code.visualstudio.com/docs/devcontainers/containers)
- [Time Series Analysis with Python](https://www.python-data-science.com/time-series-analysis)
- [RAG Agent Integration Guide](./rag-agent-mcp-integration-guide.md)