# MCP (Model Context Protocol) setup

# Source Python and TypeScript environments
if [ -f /etc/zsh/zshrc.d/python-setup.zsh ]; then
  source /etc/zsh/zshrc.d/python-setup.zsh
fi

if [ -f /etc/zsh/zshrc.d/typescript-setup.zsh ]; then
  source /etc/zsh/zshrc.d/typescript-setup.zsh
fi

# MCP specific aliases and functions
mcp-init() {
  echo "Initializing new MCP project..."
  mkdir -p server client
  
  # Set up Python server
  cd server
  pip install fastapi uvicorn python-dotenv pydantic
  touch __init__.py
  
  # Create basic server file
  cat > server.py << EOF
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Message(BaseModel):
    content: str

@app.get("/")
async def root():
    return {"message": "MCP Server is running"}

@app.post("/message")
async def process_message(message: Message):
    return {"processed": message.content}
EOF
  
  # Create start script
  cat > start.sh << EOF
#!/bin/bash
uvicorn server:app --reload --host 0.0.0.0 --port 8000
EOF
  chmod +x start.sh
  
  cd ../client
  
  # Initialize TypeScript project
  npm init -y
  npm install --save-dev typescript ts-node @types/node
  
  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOF
  
  # Create client source directory
  mkdir -p src
  
  # Create basic client file
  cat > src/client.ts << EOF
interface Message {
  content: string;
}

async function sendMessage(message: string): Promise<any> {
  const response = await fetch('http://localhost:8000/message', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ content: message }),
  });
  return response.json();
}

// Example usage
async function main() {
  try {
    const result = await sendMessage('Hello from TypeScript client');
    console.log('Response:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}

main();
EOF
  
  # Update package.json scripts
  sed -i '/"scripts": {/,/},/ c\\
  "scripts": {\\
    "build": "tsc",\\
    "start": "ts-node src/client.ts"\\
  },\\
' package.json
  
  cd ..
  echo "MCP project initialized successfully!"
  echo "To start the server: cd server && ./start.sh"
  echo "To run the client: cd client && npm start"
}

# New function for initializing a time series research project
mcp-ts-init() {
  echo "Initializing time series research project..."
  mkdir -p server client data notebooks

  # Install Python time series packages
  pip install pandas numpy matplotlib scipy statsmodels scikit-learn prophet tensorflow keras pytorch-lightning darts tsfresh pmdarima
  
  # Create Python project structure
  cd server
  mkdir -p src/models src/data src/utils src/api
  touch src/__init__.py src/models/__init__.py src/data/__init__.py src/utils/__init__.py src/api/__init__.py

  # Create FastAPI server with time series endpoints
  cat > src/api/app.py << EOF
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import pandas as pd
import numpy as np
import json
import os
from datetime import datetime, timedelta

app = FastAPI(title="Time Series API")

class TimeSeriesData(BaseModel):
    data: List[Dict[str, Any]]
    timestamp_column: str
    value_columns: List[str]
    
class ForecastRequest(BaseModel):
    data: List[Dict[str, Any]]
    timestamp_column: str
    target_column: str
    horizon: int
    freq: str = "D"
    
class ForecastResponse(BaseModel):
    forecast: List[Dict[str, Any]]
    metrics: Dict[str, float]

@app.post("/api/forecast")
async def forecast(request: ForecastRequest):
    """Generate forecasts for provided time series data"""
    try:
        # Convert to pandas for processing
        df = pd.DataFrame(request.data)
        df[request.timestamp_column] = pd.to_datetime(df[request.timestamp_column])
        df = df.set_index(request.timestamp_column)
        
        # Simple forecast using last value (placeholder - would use actual models)
        last_value = df[request.target_column].iloc[-1]
        forecast_index = pd.date_range(
            start=df.index[-1] + pd.Timedelta(1, unit=request.freq),
            periods=request.horizon,
            freq=request.freq
        )
        
        # This is a placeholder - in a real system, you'd call ML models
        forecast_values = [last_value] * request.horizon
        
        # Create forecast dataframe
        forecast_df = pd.DataFrame({
            'timestamp': forecast_index,
            'forecast': forecast_values,
            'lower_bound': [v * 0.9 for v in forecast_values],
            'upper_bound': [v * 1.1 for v in forecast_values]
        })
        
        return {
            "forecast": forecast_df.to_dict(orient="records"),
            "metrics": {"mape": 0.0, "rmse": 0.0}  # Placeholder metrics
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/anomaly-detection")
async def detect_anomalies(data: TimeSeriesData):
    """Detect anomalies in time series data"""
    try:
        df = pd.DataFrame(data.data)
        df[data.timestamp_column] = pd.to_datetime(df[data.timestamp_column])
        
        results = {}
        for col in data.value_columns:
            # Simple z-score anomaly detection (placeholder)
            values = df[col].values
            mean = np.mean(values)
            std = np.std(values)
            z_scores = [(x - mean) / std for x in values]
            anomalies = [i for i, z in enumerate(z_scores) if abs(z) > 3]
            
            results[col] = [{"index": i, "timestamp": df[data.timestamp_column][i].isoformat(), "value": float(values[i])} for i in anomalies]
            
        return {"anomalies": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"message": "Time Series Research API is running"}
EOF

  # Create requirements.txt for the server
  cat > requirements.txt << EOF
fastapi>=0.100.0
uvicorn>=0.22.0
pandas>=2.0.0
numpy>=1.24.0
scikit-learn>=1.3.0
statsmodels>=0.14.0
prophet>=1.1.4
darts>=0.24.0
tsfresh>=0.20.0
pmdarima>=2.0.3
matplotlib>=3.7.0
plotly>=5.15.0
tensorflow>=2.12.0
torch>=2.0.0
pytorch-lightning>=2.0.0
EOF

  # Create start script
  cat > start.sh << EOF
#!/bin/bash
uvicorn src.api.app:app --reload --host 0.0.0.0 --port 8000
EOF
  chmod +x start.sh
  
  # Create a utility script for data processing
  cat > src/utils/preprocessing.py << EOF
import pandas as pd
import numpy as np
from typing import List, Dict, Any, Union

def load_data(file_path: str) -> pd.DataFrame:
    """Load time series data from various file formats"""
    if file_path.endswith('.csv'):
        return pd.read_csv(file_path)
    elif file_path.endswith('.parquet'):
        return pd.read_parquet(file_path)
    elif file_path.endswith('.json'):
        return pd.read_json(file_path)
    else:
        raise ValueError(f"Unsupported file format: {file_path}")

def preprocess_time_series(df: pd.DataFrame, timestamp_col: str, value_cols: List[str]) -> pd.DataFrame:
    """Preprocess time series data"""
    # Convert timestamp column to datetime
    df[timestamp_col] = pd.to_datetime(df[timestamp_col])
    
    # Set timestamp as index
    df = df.set_index(timestamp_col)
    
    # Handle missing values
    for col in value_cols:
        df[col] = df[col].interpolate(method='time')
    
    # Resample to regular frequency (daily by default)
    df = df.resample('D').mean()
    
    return df

def create_features(df: pd.DataFrame) -> pd.DataFrame:
    """Create time-based features for time series data"""
    df = df.copy()
    df['day_of_week'] = df.index.dayofweek
    df['day_of_month'] = df.index.day
    df['month'] = df.index.month
    df['year'] = df.index.year
    df['is_weekend'] = df.index.dayofweek.isin([5, 6]).astype(int)
    
    return df
EOF

  # Create client-side TypeScript setup with cursor integration
  cd ../client
  
  # Initialize TypeScript project with cursor support
  npm init -y
  npm install --save-dev typescript ts-node @types/node
  npm install --save axios chart.js moment vega vega-lite vega-embed

  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "jsx": "react"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOF

  # Create source directory and ts client
  mkdir -p src
  
  # Create time series client API
  cat > src/api-client.ts << EOF
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8000/api';

export interface TimeSeriesPoint {
  [key: string]: any;
}

export interface TimeSeriesData {
  data: TimeSeriesPoint[];
  timestamp_column: string;
  value_columns: string[];
}

export interface ForecastRequest {
  data: TimeSeriesPoint[];
  timestamp_column: string;
  target_column: string;
  horizon: number;
  freq?: string;
}

export interface ForecastResponse {
  forecast: TimeSeriesPoint[];
  metrics: {
    [key: string]: number;
  };
}

export interface AnomalyDetectionResponse {
  anomalies: {
    [column: string]: {
      index: number;
      timestamp: string;
      value: number;
    }[];
  };
}

/**
 * Time Series API client
 */
export class TimeSeriesClient {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  /**
   * Generate forecasts for the provided time series data
   */
  async forecast(request: ForecastRequest): Promise<ForecastResponse> {
    const response = await axios.post<ForecastResponse>(
      \`\${this.baseUrl}/forecast\`,
      request
    );
    return response.data;
  }

  /**
   * Detect anomalies in the provided time series data
   */
  async detectAnomalies(data: TimeSeriesData): Promise<AnomalyDetectionResponse> {
    const response = await axios.post<AnomalyDetectionResponse>(
      \`\${this.baseUrl}/anomaly-detection\`,
      data
    );
    return response.data;
  }
}

// Export a default client instance
export default new TimeSeriesClient();
EOF

  # Create visualization utilities
  cat > src/visualizations.ts << EOF
import * as vega from 'vega';
import * as vegaLite from 'vega-lite';
import * as vegaEmbed from 'vega-embed';

/**
 * Create a time series line chart using Vega-Lite
 */
export function createTimeSeriesChart(
  containerId: string,
  data: any[],
  timestampField: string,
  valueField: string,
  title: string = 'Time Series'
) {
  const spec = {
    $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
    title,
    width: 'container',
    height: 300,
    data: { values: data },
    mark: 'line',
    encoding: {
      x: {
        field: timestampField,
        type: 'temporal',
        title: 'Time'
      },
      y: {
        field: valueField,
        type: 'quantitative',
        title: 'Value'
      }
    }
  };

  return vegaEmbed.default('#' + containerId, spec);
}

/**
 * Create a forecast chart with prediction intervals
 */
export function createForecastChart(
  containerId: string,
  historicalData: any[],
  forecastData: any[],
  timestampField: string,
  valueField: string,
  lowerBoundField: string = 'lower_bound',
  upperBoundField: string = 'upper_bound',
  title: string = 'Forecast'
) {
  // Add a source field to distinguish data
  const historical = historicalData.map(d => ({ ...d, source: 'historical' }));
  const forecast = forecastData.map(d => ({ ...d, source: 'forecast' }));
  
  const data = [...historical, ...forecast];
  
  const spec = {
    $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
    title,
    width: 'container',
    height: 300,
    data: { values: data },
    layer: [
      // Historical line
      {
        transform: [{ filter: "datum.source === 'historical'" }],
        mark: { type: 'line', color: 'steelblue' },
        encoding: {
          x: { field: timestampField, type: 'temporal', title: 'Time' },
          y: { field: valueField, type: 'quantitative', title: 'Value' }
        }
      },
      // Forecast line
      {
        transform: [{ filter: "datum.source === 'forecast'" }],
        mark: { type: 'line', color: 'orange' },
        encoding: {
          x: { field: timestampField, type: 'temporal' },
          y: { field: 'forecast', type: 'quantitative' }
        }
      },
      // Confidence interval
      {
        transform: [{ filter: "datum.source === 'forecast'" }],
        mark: { type: 'area', color: 'orange', opacity: 0.2 },
        encoding: {
          x: { field: timestampField, type: 'temporal' },
          y: { field: lowerBoundField, type: 'quantitative' },
          y2: { field: upperBoundField }
        }
      }
    ]
  };

  return vegaEmbed.default('#' + containerId, spec);
}

/**
 * Create an anomaly detection chart
 */
export function createAnomalyChart(
  containerId: string,
  data: any[],
  anomalyIndices: number[],
  timestampField: string,
  valueField: string,
  title: string = 'Anomaly Detection'
) {
  // Create anomaly points
  const anomalyPoints = anomalyIndices.map(i => data[i]);
  
  const spec = {
    $schema: 'https://vega.github.io/schema/vega-lite/v5.json',
    title,
    width: 'container',
    height: 300,
    layer: [
      // Main time series
      {
        data: { values: data },
        mark: { type: 'line', color: 'steelblue' },
        encoding: {
          x: { field: timestampField, type: 'temporal', title: 'Time' },
          y: { field: valueField, type: 'quantitative', title: 'Value' }
        }
      },
      // Anomaly points
      {
        data: { values: anomalyPoints },
        mark: { type: 'point', color: 'red', size: 100 },
        encoding: {
          x: { field: timestampField, type: 'temporal' },
          y: { field: valueField, type: 'quantitative' }
        }
      }
    ]
  };

  return vegaEmbed.default('#' + containerId, spec);
}
EOF

  # Create example client usage
  cat > src/client.ts << EOF
import { TimeSeriesClient, TimeSeriesData, ForecastRequest } from './api-client';
import { createTimeSeriesChart, createForecastChart, createAnomalyChart } from './visualizations';

// Example usage in Node.js environment
async function main() {
  try {
    const client = new TimeSeriesClient();
    
    // Generate sample data
    const now = new Date();
    const data = Array.from({ length: 100 }, (_, i) => {
      const date = new Date(now);
      date.setDate(date.getDate() - (100 - i));
      
      // Create a time series with trend and seasonality
      const trend = i * 0.1;
      const seasonality = 10 * Math.sin(i * Math.PI / 7); // Weekly seasonality
      const noise = Math.random() * 5 - 2.5;
      const value = trend + seasonality + noise;
      
      return {
        timestamp: date.toISOString().split('T')[0],
        value
      };
    });
    
    // Make forecast request
    const forecastRequest: ForecastRequest = {
      data,
      timestamp_column: 'timestamp',
      target_column: 'value',
      horizon: 14,
      freq: 'D'
    };
    
    console.log('Requesting forecast...');
    const forecastResult = await client.forecast(forecastRequest);
    console.log(\`Forecast generated with \${forecastResult.forecast.length} points\`);
    
    // Detect anomalies
    const anomalyRequest: TimeSeriesData = {
      data,
      timestamp_column: 'timestamp',
      value_columns: ['value']
    };
    
    console.log('Detecting anomalies...');
    const anomalyResult = await client.detectAnomalies(anomalyRequest);
    console.log(\`Detected \${anomalyResult.anomalies.value.length} anomalies\`);
    
    // In a browser environment, you would use the visualization functions:
    // createTimeSeriesChart('chart1', data, 'timestamp', 'value', 'Sample Time Series');
    // createForecastChart('chart2', data, forecastResult.forecast, 'timestamp', 'value');
    // createAnomalyChart('chart3', data, anomalyResult.anomalies.value.map(a => a.index), 'timestamp', 'value');
  } catch (error) {
    console.error('Error:', error);
  }
}

// Only run in Node.js environment
if (typeof window === 'undefined') {
  main();
}

// Export for browser usage
export { createTimeSeriesChart, createForecastChart, createAnomalyChart };
EOF

  # Update package.json scripts
  sed -i '/"scripts": {/,/},/ c\\
  "scripts": {\\
    "build": "tsc",\\
    "start": "ts-node src/client.ts"\\
  },\\
' package.json

  # Create example HTML page for browser visualization
  cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Time Series Dashboard</title>
  <script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #f5f5f5;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
    }
    .chart-container {
      background-color: white;
      border-radius: 5px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin-bottom: 20px;
      padding: 20px;
    }
    h1, h2 {
      color: #333;
    }
    .controls {
      margin-bottom: 20px;
    }
    button {
      background-color: #4CAF50;
      border: none;
      color: white;
      padding: 10px 15px;
      text-align: center;
      text-decoration: none;
      display: inline-block;
      font-size: 16px;
      margin: 4px 2px;
      cursor: pointer;
      border-radius: 4px;
    }
    input, select {
      padding: 8px;
      margin: 5px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Time Series Analysis Dashboard</h1>
    
    <div class="controls">
      <button id="loadData">Load Sample Data</button>
      <button id="forecast">Generate Forecast</button>
      <button id="detectAnomalies">Detect Anomalies</button>
      <span>Horizon: </span>
      <input type="number" id="horizon" value="14" min="1" max="365">
    </div>
    
    <div class="chart-container">
      <h2>Historical Data</h2>
      <div id="chart1"></div>
    </div>
    
    <div class="chart-container">
      <h2>Forecast</h2>
      <div id="chart2"></div>
    </div>
    
    <div class="chart-container">
      <h2>Anomaly Detection</h2>
      <div id="chart3"></div>
    </div>
  </div>
  
  <script>
    // This would be replaced by your bundled JavaScript
    document.addEventListener('DOMContentLoaded', function() {
      // In a real application, you would import the client and visualization functions
      // For now, just display a message that this is a placeholder
      document.getElementById('loadData').addEventListener('click', function() {
        alert('This is a placeholder. In a real application, this would load data and create visualizations using the TypeScript client.');
      });
    });
  </script>
</body>
</html>
EOF

  # Create a sample Jupyter notebook for time series analysis
  cd ../notebooks
  
  cat > time_series_analysis.ipynb << EOF
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Time Series Analysis Notebook\n",
    "\n",
    "This notebook demonstrates time series analysis techniques using Python libraries."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Import necessary libraries\n",
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "from datetime import datetime, timedelta\n",
    "\n",
    "# Statistical and forecasting libraries\n",
    "import statsmodels.api as sm\n",
    "from statsmodels.tsa.seasonal import seasonal_decompose\n",
    "from statsmodels.tsa.statespace.sarimax import SARIMAX\n",
    "\n",
    "# For evaluation\n",
    "from sklearn.metrics import mean_absolute_error, mean_squared_error\n",
    "\n",
    "# Set plot style\n",
    "plt.style.use('ggplot')\n",
    "sns.set(style=\"whitegrid\")\n",
    "%matplotlib inline"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Generate Sample Time Series Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Generate sample time series data\n",
    "np.random.seed(42)\n",
    "date_rng = pd.date_range(start='2020-01-01', end='2023-01-01', freq='D')\n",
    "n = len(date_rng)\n",
    "\n",
    "# Create a time series with trend, seasonality, and noise\n",
    "trend = np.linspace(10, 30, n)  # Upward trend\n",
    "yearly_seasonality = 5 * np.sin(2 * np.pi * np.arange(n) / 365)  # Yearly cycle\n",
    "weekly_seasonality = 3 * np.sin(2 * np.pi * np.arange(n) / 7)    # Weekly cycle\n",
    "noise = np.random.normal(0, 2, n)                               # Random noise\n",
    "\n",
    "# Combine components\n",
    "values = trend + yearly_seasonality + weekly_seasonality + noise\n",
    "\n",
    "# Create DataFrame\n",
    "df = pd.DataFrame({\n",
    "    'date': date_rng,\n",
    "    'value': values\n",
    "})\n",
    "\n",
    "# Add anomalies\n",
    "anomaly_indices = [100, 200, 300, 400, 500]\n",
    "df.loc[anomaly_indices, 'value'] += 15  # Add spikes\n",
    "\n",
    "# Display first few rows\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Exploratory Data Analysis"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Plot the time series\n",
    "plt.figure(figsize=(14, 6))\n",
    "plt.plot(df['date'], df['value'])\n",
    "plt.title('Sample Time Series')\n",
    "plt.xlabel('Date')\n",
    "plt.ylabel('Value')\n",
    "plt.grid(True)\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Time Series Decomposition"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Set date as index for decomposition\n",
    "df.set_index('date', inplace=True)\n",
    "\n",
    "# Decompose the time series\n",
    "decomposition = seasonal_decompose(df['value'], model='additive', period=365)\n",
    "\n",
    "# Plot decomposition\n",
    "fig, (ax1, ax2, ax3, ax4) = plt.subplots(4, 1, figsize=(14, 12))\n",
    "decomposition.observed.plot(ax=ax1)\n",
    "ax1.set_title('Observed')\n",
    "decomposition.trend.plot(ax=ax2)\n",
    "ax2.set_title('Trend')\n",
    "decomposition.seasonal.plot(ax=ax3)\n",
    "ax3.set_title('Seasonal')\n",
    "decomposition.resid.plot(ax=ax4)\n",
    "ax4.set_title('Residual')\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Anomaly Detection"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Detect anomalies using Z-score\n",
    "from scipy import stats\n",
    "\n",
    "# Calculate Z-scores\n",
    "z_scores = np.abs(stats.zscore(decomposition.resid.dropna()))\n",
    "threshold = 3\n",
    "outliers = np.where(z_scores > threshold)[0]\n",
    "\n",
    "# Get original indices (accounting for NaN values at start/end of residuals)\n",
    "resid_idx = decomposition.resid.dropna().index\n",
    "outlier_dates = resid_idx[outliers]\n",
    "\n",
    "# Plot the time series with anomalies highlighted\n",
    "plt.figure(figsize=(14, 6))\n",
    "plt.plot(df.index, df['value'], label='Original')\n",
    "plt.scatter(outlier_dates, df.loc[outlier_dates, 'value'], color='red', s=50, label='Anomalies')\n",
    "plt.title('Time Series with Detected Anomalies')\n",
    "plt.xlabel('Date')\n",
    "plt.ylabel('Value')\n",
    "plt.legend()\n",
    "plt.grid(True)\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Forecasting"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Split data into train and test\n",
    "train = df[:'2022-06-01']\n",
    "test = df['2022-06-02':]\n",
    "\n",
    "# Fit SARIMA model\n",
    "model = SARIMAX(train['value'], \n",
    "                order=(1, 1, 1),\n",
    "                seasonal_order=(1, 1, 1, 12),\n",
    "                enforce_stationarity=False,\n",
    "                enforce_invertibility=False)\n",
    "\n",
    "model_fit = model.fit()\n",
    "print(model_fit.summary())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Forecast\n",
    "forecast = model_fit.get_forecast(steps=len(test))\n",
    "forecast_ci = forecast.conf_int()\n",
    "\n",
    "# Plot forecast\n",
    "plt.figure(figsize=(14, 6))\n",
    "plt.plot(train.index, train['value'], label='Historical Data')\n",
    "plt.plot(test.index, test['value'], label='Actual Values')\n",
    "plt.plot(test.index, forecast.predicted_mean, label='Forecast')\n",
    "plt.fill_between(test.index, \n",
    "                 forecast_ci.iloc[:, 0], \n",
    "                 forecast_ci.iloc[:, 1], \n",
    "                 color='k', alpha=0.1, label='95% Confidence Interval')\n",
    "plt.title('Time Series Forecast')\n",
    "plt.xlabel('Date')\n",
    "plt.ylabel('Value')\n",
    "plt.legend()\n",
    "plt.grid(True)\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Evaluate Forecast"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Calculate performance metrics\n",
    "mae = mean_absolute_error(test['value'], forecast.predicted_mean)\n",
    "rmse = np.sqrt(mean_squared_error(test['value'], forecast.predicted_mean))\n",
    "mape = np.mean(np.abs((test['value'] - forecast.predicted_mean) / test['value'])) * 100\n",
    "\n",
    "print(f'Mean Absolute Error (MAE): {mae:.4f}')\n",
    "print(f'Root Mean Square Error (RMSE): {rmse:.4f}')\n",
    "print(f'Mean Absolute Percentage Error (MAPE): {mape:.4f}%')"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.10.12"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

  # Create sample data directory structure
  cd ../data
  mkdir -p raw processed

  # Create README with usage instructions
  cd ..
  cat > README.md << EOF
# Time Series Research Project

This project provides tools for time series analysis, forecasting, and anomaly detection using Python and TypeScript.

## Project Structure

- **server/** - FastAPI server with time series endpoints
- **client/** - TypeScript client with visualization capabilities
- **data/** - Data storage (raw and processed)
- **notebooks/** - Jupyter notebooks for analysis

## Getting Started

### Server

1. Navigate to the server directory:
   \`\`\`
   cd server
   \`\`\`

2. Install dependencies:
   \`\`\`
   pip install -r requirements.txt
   \`\`\`

3. Start the server:
   \`\`\`
   ./start.sh
   \`\`\`

### Client

1. Navigate to the client directory:
   \`\`\`
   cd client
   \`\`\`

2. Install dependencies:
   \`\`\`
   npm install
   \`\`\`

3. Build and run the client:
   \`\`\`
   npm run build
   npm start
   \`\`\`

4. For browser visualization, open \`index.html\` in a web browser after building.

### Jupyter Notebooks

Navigate to the notebooks directory and start Jupyter:

\`\`\`
cd notebooks
jupyter notebook
\`\`\`

## Features

- Time series data preprocessing
- Time series visualization
- Forecasting with confidence intervals
- Anomaly detection
- Interactive dashboard

## API Documentation

The FastAPI server includes Swagger documentation available at:
http://localhost:8000/docs
EOF

  echo "Time series research project initialized successfully!"
  echo "Project structure:"
  echo "- server/: FastAPI backend with time series endpoints"
  echo "- client/: TypeScript client with visualization tools"
  echo "- data/: For storing time series datasets"
  echo "- notebooks/: Jupyter notebooks for analysis"
  echo ""
  echo "To start the server: cd server && ./start.sh"
  echo "To run the client: cd client && npm start"
}

# cursor integration helper function
mcp-cursor-init() {
  echo "Setting up cursor integration for MCP..."
  mkdir -p cursor-client
  
  cd cursor-client
  
  # Initialize TypeScript project
  npm init -y
  npm install --save-dev typescript ts-node @types/node
  npm install --save axios openai
  
  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.spec.ts"]
}
EOF
  
  # Create source directory
  mkdir -p src
  
  # Create cursor client
  cat > src/cursor-client.ts << EOF
import { Configuration, OpenAIApi } from 'openai';
import * as fs from 'fs';
import * as path from 'path';
import axios from 'axios';

/**
 * Options for the CursorClient
 */
export interface CursorClientOptions {
  apiKey?: string;
  baseUrl?: string;
  model?: string;
  temperature?: number;
  maxTokens?: number;
}

/**
 * Response from code generation
 */
export interface CodeGenerationResponse {
  code: string;
  explanation: string;
}

/**
 * Client for interfacing with Cursor/OpenAI for code generation and editing
 */
export class CursorClient {
  private openai: OpenAIApi | null = null;
  private apiKey: string;
  private baseUrl: string;
  private model: string;
  private temperature: number;
  private maxTokens: number;

  constructor(options: CursorClientOptions = {}) {
    this.apiKey = options.apiKey || process.env.OPENAI_API_KEY || '';
    this.baseUrl = options.baseUrl || 'https://api.openai.com/v1';
    this.model = options.model || 'gpt-4';
    this.temperature = options.temperature !== undefined ? options.temperature : 0.2;
    this.maxTokens = options.maxTokens || 2048;
    
    if (this.apiKey) {
      const configuration = new Configuration({ apiKey: this.apiKey });
      this.openai = new OpenAIApi(configuration);
    }
  }

  /**
   * Generate code based on a prompt
   */
  async generateCode(prompt: string): Promise<CodeGenerationResponse> {
    try {
      if (!this.openai) {
        throw new Error('OpenAI API key not configured');
      }

      const response = await this.openai.createChatCompletion({
        model: this.model,
        messages: [
          { role: 'system', content: 'You are an expert programmer. Generate high-quality, well-documented code based on the prompt.' },
          { role: 'user', content: prompt }
        ],
        temperature: this.temperature,
        max_tokens: this.maxTokens
      });

      const content = response.data.choices[0]?.message?.content || '';
      
      // Extract code blocks from the response
      const codeRegex = /\`\`\`(?:javascript|typescript|js|ts)?\n([\s\S]*?)\n\`\`\`/g;
      let match;
      let code = '';
      
      while ((match = codeRegex.exec(content)) !== null) {
        code += match[1] + '\n\n';
      }
      
      // If no code blocks found, use the entire response
      if (!code.trim()) {
        code = content;
      }

      return {
        code: code.trim(),
        explanation: content
      };
    } catch (error) {
      console.error('Error generating code:', error);
      throw error;
    }
  }

  /**
   * Edit existing code based on instructions
   */
  async editCode(code: string, instructions: string): Promise<CodeGenerationResponse> {
    try {
      if (!this.openai) {
        throw new Error('OpenAI API key not configured');
      }

      const prompt = \`I have the following code:\n\n\`\`\`\n\${code}\n\`\`\`\n\nInstructions: \${instructions}\n\nPlease provide the updated code.\`;

      const response = await this.openai.createChatCompletion({
        model: this.model,
        messages: [
          { role: 'system', content: 'You are an expert programmer. Edit the provided code according to the instructions.' },
          { role: 'user', content: prompt }
        ],
        temperature: this.temperature,
        max_tokens: this.maxTokens
      });

      const content = response.data.choices[0]?.message?.content || '';
      
      // Extract code blocks from the response
      const codeRegex = /\`\`\`(?:javascript|typescript|js|ts)?\n([\s\S]*?)\n\`\`\`/g;
      let match;
      let updatedCode = '';
      
      while ((match = codeRegex.exec(content)) !== null) {
        updatedCode += match[1] + '\n\n';
      }
      
      // If no code blocks found, assume the entire response is code
      if (!updatedCode.trim()) {
        updatedCode = content;
      }

      return {
        code: updatedCode.trim(),
        explanation: content
      };
    } catch (error) {
      console.error('Error editing code:', error);
      throw error;
    }
  }

  /**
   * Generate a complete solution for a given problem
   */
  async createSolution(problem: string, language: string = 'typescript'): Promise<CodeGenerationResponse> {
    try {
      if (!this.openai) {
        throw new Error('OpenAI API key not configured');
      }

      const prompt = \`Create a complete solution for the following problem using \${language}:\n\n\${problem}\n\nPlease include comments and explain your approach.\`;

      const response = await this.openai.createChatCompletion({
        model: this.model,
        messages: [
          { role: 'system', content: \`You are an expert \${language} programmer. Generate a high-quality, well-documented solution.\` },
          { role: 'user', content: prompt }
        ],
        temperature: this.temperature,
        max_tokens: this.maxTokens
      });

      const content = response.data.choices[0]?.message?.content || '';
      
      // Extract code blocks from the response
      const codeRegex = /\`\`\`(?:javascript|typescript|js|ts|python|py|java|c#|csharp)?\n([\s\S]*?)\n\`\`\`/g;
      let match;
      let solution = '';
      
      while ((match = codeRegex.exec(content)) !== null) {
        solution += match[1] + '\n\n';
      }
      
      // If no code blocks found, use the entire response
      if (!solution.trim()) {
        solution = content;
      }

      return {
        code: solution.trim(),
        explanation: content
      };
    } catch (error) {
      console.error('Error creating solution:', error);
      throw error;
    }
  }

  /**
   * Save generated code to a file
   */
  saveToFile(code: string, filePath: string): void {
    try {
      const dirPath = path.dirname(filePath);
      
      // Create directory if it doesn't exist
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
      
      fs.writeFileSync(filePath, code);
      console.log(\`Code saved to \${filePath}\`);
    } catch (error) {
      console.error('Error saving code to file:', error);
      throw error;
    }
  }
}

// Export a default client instance
export default new CursorClient();
EOF

  # Create example usage
  cat > src/example.ts << EOF
import { CursorClient } from './cursor-client';

async function example() {
  // Initialize client with environment variable for API key
  const client = new CursorClient({
    model: 'gpt-4', // or 'gpt-3.5-turbo' for faster, less expensive responses
    temperature: 0.2
  });

  try {
    // Generate a simple function
    console.log('Generating code...');
    const result = await client.generateCode(
      'Create a TypeScript function that calculates the Fibonacci sequence up to n terms.'
    );
    
    console.log('Generated Code:');
    console.log(result.code);
    
    // Edit existing code
    console.log('\nEditing code...');
    const editResult = await client.editCode(
      result.code,
      'Modify the function to use memoization to improve performance.'
    );
    
    console.log('Edited Code:');
    console.log(editResult.code);
    
    // Save the edited code to a file
    client.saveToFile(editResult.code, './output/fibonacci.ts');
    
    // Create a complete solution
    console.log('\nCreating a complete solution...');
    const solutionResult = await client.createSolution(
      'Create a time series analysis utility that can detect outliers in a dataset.',
      'typescript'
    );
    
    console.log('Solution:');
    console.log(solutionResult.code);
    
    // Save the solution to a file
    client.saveToFile(solutionResult.code, './output/time-series-analysis.ts');
    
  } catch (error) {
    console.error('Error in example:', error);
  }
}

// Run the example if this file is executed directly
if (require.main === module) {
  example();
}
EOF

  # Update package.json scripts
  sed -i '/"scripts": {/,/},/ c\\
  "scripts": {\\
    "build": "tsc",\\
    "start": "ts-node src/example.ts",\\
    "generate": "ts-node src/cursor-client.ts"\\
  },\\
' package.json

  # Create output directory
  mkdir -p output

  # Create README
  cat > README.md << EOF
# Cursor Client for MCP

This package provides a client for integrating with Cursor and OpenAI's API for code generation and editing in the MCP environment.

## Setup

1. Install dependencies:
   \`\`\`
   npm install
   \`\`\`

2. Set your OpenAI API key:
   \`\`\`
   export OPENAI_API_KEY=your-api-key
   \`\`\`

3. Build the package:
   \`\`\`
   npm run build
   \`\`\`

## Usage

```typescript
import { CursorClient } from './dist/cursor-client';

async function main() {
  const client = new CursorClient();
  
  // Generate code
  const result = await client.generateCode(
    'Create a function that calculates the Fibonacci sequence'
  );
  
  console.log(result.code);
  
  // Save to file
  client.saveToFile(result.code, './fibonacci.ts');
}

main();
```

## Features

- Generate code from natural language prompts
- Edit existing code based on instructions
- Create complete solutions for programming problems
- Save generated code to files

## Configuration

You can configure the client with various options:

```typescript
const client = new CursorClient({
  apiKey: 'your-api-key', // Alternatively use OPENAI_API_KEY env var
  model: 'gpt-4', // or 'gpt-3.5-turbo'
  temperature: 0.2,
  maxTokens: 2048
});
```
EOF

  cd ..
  echo "Cursor integration setup completed!"
  echo "Navigate to cursor-client directory to use the cursor client"
  echo "Remember to set your OpenAI API key with: export OPENAI_API_KEY=your-api-key"
}