# MCP Environment: Time Series Analysis and LLM Integration

This document provides an overview of the Model Context Protocol (MCP) environment's capabilities for time series analysis and large language model (LLM) integration.

## Overview

The MCP environment combines Python and TypeScript tools to create a powerful platform for researching and developing time series analysis systems that leverage large language models. It's designed to support experimentation with different techniques for time series forecasting, anomaly detection, and pattern recognition, enhanced by LLM capabilities.

## Environment Features

### Python Libraries

The environment includes major Python libraries for time series analysis:

- **Data Processing**: `pandas`, `numpy`, `scipy`
- **Visualization**: `matplotlib`, `seaborn`, `plotly`, `bokeh`, `holoviews`, `hvplot`
- **Machine Learning**: `scikit-learn`, `statsmodels`
- **Deep Learning**: `torch`, `tensorflow`, `keras`
- **Time Series Specific**: `dask`, `pmdarima`, `prophet`
- **Jupyter Tools**: `jupyterlab`, `ipywidgets`

### TypeScript/JavaScript Tools

For client-side development and visualization:

- **Core Tools**: Node.js, TypeScript, npm
- **Visualization**: Vega, Vega-Lite for interactive visualizations
- **API Integration**: Axios for HTTP requests
- **LLM Integration**: OpenAI library for model interaction

### Development Tools

The environment provides several custom functions to accelerate development:

- `mcp-ts-init`: Initialize a complete time series research project
- `mcp-cursor-init`: Set up Cursor AI integration for code generation
- `mcp-init`: Initialize a basic MCP project structure

## Time Series Project Structure

When you run `mcp-ts-init`, it creates a complete project with:

```
├── server/
│   ├── src/
│   │   ├── api/
│   │   │   └── app.py           # FastAPI endpoints
│   │   ├── models/
│   │   ├── data/
│   │   └── utils/
│   │       └── preprocessing.py # Time series preprocessing
│   └── requirements.txt         # Python dependencies
├── client/
│   ├── src/
│   │   ├── api-client.ts        # TypeScript API client
│   │   ├── visualizations.ts    # Visualization utilities
│   │   └── client.ts            # Example usage
│   ├── index.html               # Dashboard template
│   └── package.json             # Node.js dependencies
├── notebooks/
│   └── time_series_analysis.ipynb # Jupyter notebook
└── data/
    ├── raw/
    └── processed/
```

## Key Capabilities

### Time Series Forecasting

The environment supports multiple forecasting approaches:

1. **Statistical Methods**: ARIMA, SARIMA, Exponential Smoothing
2. **Machine Learning**: Regression, RandomForest, Gradient Boosting
3. **Deep Learning**: RNNs, LSTMs, Transformer models
4. **Hybrid Models**: Combining traditional and LLM approaches

### Anomaly Detection

Identify unusual patterns in time series data:

1. **Statistical Approaches**: Z-scores, IQR methods
2. **ML-based Detection**: Isolation Forests, One-Class SVM
3. **Deep Learning**: Autoencoders for unsupervised anomaly detection
4. **LLM-Enhanced**: Using LLMs to explain and validate anomalies

### LLM Integration (Cursor)

The MCP environment includes tools for integrating LLMs into your workflow:

1. **Code Generation**: Generate time series models and analysis code
2. **Pattern Explanation**: Use LLMs to explain patterns in your data
3. **Augmented Analysis**: Combine traditional time series methods with LLM insights
4. **Documentation**: Auto-generate documentation for your models and findings

## Advanced Capabilities

### RAG and Agent Components for Cryptocurrency Analysis

The MCP environment can be extended with on-demand Retrieval-Augmented Generation (RAG) and Agent capabilities, particularly useful for cryptocurrency market analysis.

#### What These Components Offer

- **RAG Components**: Connect AI models with cryptocurrency market data, news, and documentation
- **Agent Framework**: Create autonomous agents that can perform complex analysis tasks
- **Cryptocurrency Connectors**: Ready-to-use connectors for popular exchanges and data sources
- **Example Notebooks**: Learn by example with pre-built cryptocurrency analysis notebooks

#### Installation

These components are designed for on-demand installation within the MCP container:

1. Open the MCP container:
   ```bash
   npm run mcp
   ```

2. Run the installation script:
   ```bash
   /workspace/mcp/install-rag-agent.sh
   ```

The installation script will detect your network environment (global or China) and configure appropriate mirrors and settings automatically.

#### Usage

After installation:

1. Source the environment variables:
   ```bash
   source /workspace/mcp/setup-rag-agent-env.sh
   ```

2. Launch Jupyter Lab with the example notebooks:
   ```bash
   /workspace/mcp/launch-rag-agent.sh
   ```

3. Explore the example notebooks in:
   - `/workspace/mcp/rag/examples/`
   - `/workspace/mcp/agent/examples/`

For more information, see:
- [RAG and Agent Integration Guide](./guides/rag-agent-mcp-integration-guide.md)
- [When to Use RAG and Agent Components](./guides/when-to-use-rag-agent.md)

## Getting Started

### Initialize a Time Series Project

```bash
# Start the container and open a terminal
mcp-ts-init
```

### Run the FastAPI Server

```bash
cd server
./start.sh
```

### Start the TypeScript Client

```bash
cd client
npm install
npm start
```

### Open Jupyter Notebooks

```bash
cd notebooks
jupyter notebook
```

## Examples

### Example: Forecasting with SARIMA

```python
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.statespace.sarimax import SARIMAX

# Load data
df = pd.read_csv('data/processed/my_time_series.csv')
df['date'] = pd.to_datetime(df['date'])
df = df.set_index('date')

# Split data
train = df.iloc[:-30]
test = df.iloc[-30:]

# Fit model
model = SARIMAX(train['value'], order=(1, 1, 1), 
                seasonal_order=(1, 1, 1, 12))
results = model.fit()

# Forecast
forecast = results.get_forecast(steps=30)
forecast_ci = forecast.conf_int()

# Plot
plt.figure(figsize=(12, 6))
plt.plot(train.index, train['value'], label='Training Data')
plt.plot(test.index, test['value'], label='Actual')
plt.plot(test.index, forecast.predicted_mean, label='Forecast')
plt.fill_between(test.index, 
                forecast_ci.iloc[:, 0], 
                forecast_ci.iloc[:, 1], color='k', alpha=0.2)
plt.legend()
plt.show()
```

### Example: LLM-Enhanced Analysis

```typescript
import { CursorClient } from './cursor-client';

async function analyzeTimeSeries() {
  const client = new CursorClient();
  
  const prompt = `
  I have a time series showing weekly sales data with the following characteristics:
  - Strong weekly seasonality
  - Yearly holiday peaks
  - Recent unexpected drop in values
  - Some missing data points
  
  What analysis techniques would you recommend, and can you generate code
  to implement the top 3 approaches?
  `;
  
  const result = await client.generateCode(prompt);
  console.log(result.explanation);
  
  // Save the generated code
  client.saveToFile(result.code, './src/generated-analysis.ts');
}

analyzeTimeSeries();
```

## Resources

- [Time Series with Python Documentation](https://www.statsmodels.org/stable/tsa.html)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Vega-Lite Documentation](https://vega.github.io/vega-lite/)
- [OpenAI API Documentation](https://platform.openai.com/docs/)