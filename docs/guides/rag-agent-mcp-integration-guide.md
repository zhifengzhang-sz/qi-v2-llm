# Setting Up RAG and Agent Components in the MCP Environment

This guide explains how to integrate RAG (Retrieval-Augmented Generation) for cryptocurrency data and agent-based capabilities into the existing MCP development environment.

## Overview

Instead of creating separate containers, we'll extend the MCP container with RAG and agent capabilities, keeping the overall architecture simpler while adding powerful new functionality.

## Directory Structure

We'll add the following structure to the MCP workspace:

```
mcp-workspace/
├── ...existing directories...
├── rag/
│   ├── data/
│   │   ├── crypto/             # Cryptocurrency market data
│   │   │   ├── raw/            # Raw data from exchanges, news sources, etc.
│   │   │   └── processed/      # Processed and indexed data
│   │   └── embeddings/         # Vector embeddings storage
│   ├── src/
│   │   ├── connectors/         # Data source connectors (exchanges, news APIs)
│   │   ├── indexers/           # Tools for creating and updating indices
│   │   ├── retrievers/         # Components for retrieving relevant information
│   │   └── utils/              # Utility functions
│   └── examples/               # Example notebooks demonstrating RAG capabilities
└── agent/
    ├── src/
    │   ├── tools/              # Tool definitions for agent use
    │   ├── workflows/          # Predefined agent workflows
    │   ├── memory/             # Agent memory management
    │   └── models/             # Agent reasoning components
    ├── examples/               # Example notebooks demonstrating agent capabilities
    └── configs/                # Configuration files for different agent setups
```

## Implementation Steps

### 1. Extend the MCP Dockerfile

Update the MCP Dockerfile to include the necessary dependencies for RAG and agent components:

```dockerfile
# Add RAG dependencies
RUN pip install langchain chromadb sentence-transformers faiss-cpu tiktoken pymupdf

# Add agent dependencies
RUN pip install langchain-experimental guidance openai-function-call 

# Add crypto data dependencies
RUN pip install ccxt pandas-ta pycoingecko cryptofeed websocket-client
```

### 2. Create the Directory Structure

Initialize the directory structure for RAG and agent components:

```bash
mkdir -p /workspace/mcp/rag/data/crypto/{raw,processed}
mkdir -p /workspace/mcp/rag/data/embeddings
mkdir -p /workspace/mcp/rag/src/{connectors,indexers,retrievers,utils}
mkdir -p /workspace/mcp/rag/examples

mkdir -p /workspace/mcp/agent/src/{tools,workflows,memory,models}
mkdir -p /workspace/mcp/agent/examples
mkdir -p /workspace/mcp/agent/configs
```

### 3. Initialize Basic Components

Create starter files to implement core functionality.

#### Basic RAG Implementation

Create a basic implementation for RAG:

```python
# /workspace/mcp/rag/src/utils/vector_store.py
from langchain.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings

def get_vector_store(collection_name, embedding_model="sentence-transformers/all-MiniLM-L6-v2"):
    """Initialize or load a vector store with the specified embedding model."""
    embeddings = HuggingFaceEmbeddings(model_name=embedding_model)
    
    # Path where vector store will be saved
    persist_directory = f"/workspace/mcp/rag/data/embeddings/{collection_name}"
    
    # Create or load the vector store
    vector_store = Chroma(
        collection_name=collection_name,
        embedding_function=embeddings,
        persist_directory=persist_directory
    )
    
    return vector_store
```

#### Basic Crypto Data Connector

Create a connector for cryptocurrency data:

```python
# /workspace/mcp/rag/src/connectors/crypto_connector.py
import ccxt
import pandas as pd
from datetime import datetime, timedelta

class CryptoDataConnector:
    """Connector for retrieving cryptocurrency market data from exchanges."""
    
    def __init__(self, exchange_id='binance'):
        self.exchange = getattr(ccxt, exchange_id)({
            'enableRateLimit': True,
        })
    
    def get_ohlcv(self, symbol, timeframe='1d', limit=100):
        """
        Fetch OHLCV (Open, High, Low, Close, Volume) data for a symbol.
        
        Args:
            symbol: Trading pair (e.g., 'BTC/USDT')
            timeframe: Time interval (e.g., '1m', '1h', '1d')
            limit: Number of candles to fetch
            
        Returns:
            pandas.DataFrame: OHLCV data with datetime index
        """
        ohlcv = self.exchange.fetch_ohlcv(symbol, timeframe, limit=limit)
        df = pd.DataFrame(ohlcv, columns=['timestamp', 'open', 'high', 'low', 'close', 'volume'])
        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
        df.set_index('timestamp', inplace=True)
        return df
    
    def get_tickers(self, symbols=None):
        """
        Fetch current ticker data for one or more symbols.
        
        Args:
            symbols: List of symbols or None for all available tickers
            
        Returns:
            dict: Ticker data
        """
        return self.exchange.fetch_tickers(symbols)
    
    def get_market_news(self, symbol, days=7):
        """
        Placeholder for retrieving news related to a symbol.
        In a real implementation, this would connect to news APIs.
        """
        # This is a placeholder - implement with actual news API
        return f"Would fetch news for {symbol} from the last {days} days"
```

#### Basic Agent Implementation

Create a simple agent implementation:

```python
# /workspace/mcp/agent/src/models/base_agent.py
from langchain.agents import AgentExecutor, create_react_agent
from langchain.tools import BaseTool
from langchain_core.prompts import PromptTemplate
from langchain_core.language_models import LLM

class MCPAgent:
    """Base agent class for the MCP environment."""
    
    def __init__(self, llm, tools=None, memory=None):
        """
        Initialize the agent with language model and tools.
        
        Args:
            llm: Language model to use (DeepSeek, OpenAI, etc.)
            tools: List of tools available to the agent
            memory: Memory object for the agent
        """
        self.llm = llm
        self.tools = tools or []
        self.memory = memory
        self.agent_executor = None
        
    def create_agent(self):
        """Create the agent executor."""
        prompt = PromptTemplate.from_template(
            """You are an expert in cryptocurrency markets and time series analysis.
            You have access to various tools to help analyze market data and make predictions.
            
            {tools}
            
            Use the following format:
            Question: the input question
            Thought: your reasoning about what to do
            Action: the action to take, should be one of [{tool_names}]
            Action Input: the input to the action
            Observation: the result of the action
            ... (this Thought/Action/Action Input/Observation can repeat N times)
            Thought: I now know the final answer
            Final Answer: the final answer to the original input question
            
            Question: {input}
            {agent_scratchpad}"""
        )
        
        agent = create_react_agent(
            llm=self.llm,
            tools=self.tools,
            prompt=prompt
        )
        
        self.agent_executor = AgentExecutor(
            agent=agent,
            tools=self.tools,
            memory=self.memory,
            verbose=True,
            handle_parsing_errors=True,
            max_iterations=10
        )
        
        return self.agent_executor
    
    def run(self, query):
        """Run the agent on a query."""
        if not self.agent_executor:
            self.create_agent()
        
        return self.agent_executor.invoke({"input": query})
```

#### Example Tool Implementation

Create a sample tool for the agent:

```python
# /workspace/mcp/agent/src/tools/crypto_tools.py
from langchain.tools import BaseTool
import sys
import os

# Add RAG module to path to import the connector
sys.path.append("/workspace/mcp")
from rag.src.connectors.crypto_connector import CryptoDataConnector

class CryptoOHLCVTool(BaseTool):
    """Tool for retrieving OHLCV data for cryptocurrency pairs."""
    
    name = "crypto_ohlcv"
    description = "Get historical OHLCV data for a cryptocurrency pair"
    
    def __init__(self):
        super().__init__()
        self.connector = CryptoDataConnector()
    
    def _run(self, query):
        """
        Run the tool on the query.
        
        Args:
            query: String in format "SYMBOL, TIMEFRAME, LIMIT" 
                   Example: "BTC/USDT, 1d, 30"
        
        Returns:
            String representation of the OHLCV data
        """
        try:
            parts = query.replace(" ", "").split(",")
            symbol = parts[0]
            timeframe = parts[1] if len(parts) > 1 else '1d'
            limit = int(parts[2]) if len(parts) > 2 else 30
            
            data = self.connector.get_ohlcv(symbol, timeframe, limit)
            return str(data.tail(10))
        
        except Exception as e:
            return f"Error fetching OHLCV data: {str(e)}"
```

### 4. Create Example Notebooks

Create example notebooks to demonstrate the functionality:

#### RAG Example Notebook

```python
# /workspace/mcp/rag/examples/crypto_rag_example.ipynb
# Example notebook showing how to use the RAG system with crypto data

import sys
sys.path.append("/workspace/mcp")

from rag.src.utils.vector_store import get_vector_store
from rag.src.connectors.crypto_connector import CryptoDataConnector
import pandas as pd
import matplotlib.pyplot as plt

# Initialize a crypto data connector
connector = CryptoDataConnector()

# Fetch some BTC data
btc_data = connector.get_ohlcv("BTC/USDT", "1d", 100)

# Display the data
print("Bitcoin OHLCV Data:")
display(btc_data.head())

# Plot the close price
plt.figure(figsize=(12, 6))
btc_data['close'].plot()
plt.title('Bitcoin Close Price')
plt.xlabel('Date')
plt.ylabel('Price (USDT)')
plt.grid(True)
plt.show()

# Example of how RAG would work
# In a real implementation, you would:
# 1. Collect news articles, analysis, etc.
# 2. Process and embed them
# 3. Store in the vector database
# 4. Retrieve relevant information based on queries

# For demonstration, create a dummy vector store
print("\nExample of RAG query (simulated):")
print("Query: 'What factors affected Bitcoin price in the last week?'")
print("\nRetrieved context (simulated):")
print("1. Federal Reserve announced interest rate changes on [date]")
print("2. Major institutional investor purchased $X million in BTC on [date]")
print("3. Regulatory news from [country] affected market sentiment")

print("\nRAG-enhanced response (simulated):")
print("Based on recent market data, Bitcoin price was affected by several factors:")
print("1. The Federal Reserve's interest rate announcement led to a price drop of X%")
print("2. Following the institutional purchase, there was a price recovery of Y%")
print("3. The overall trend remains [bullish/bearish] based on technical indicators")
```

#### Agent Example Notebook

```python
# /workspace/mcp/agent/examples/crypto_agent_example.ipynb
# Example notebook showing how to use the agent system

import sys
sys.path.append("/workspace/mcp")

from agent.src.models.base_agent import MCPAgent
from agent.src.tools.crypto_tools import CryptoOHLCVTool
from langchain_core.language_models import LLM
import os

# This is a placeholder for the real implementation
# You would use DeepSeek, OpenAI, or another model
class MockLLM(LLM):
    def _call(self, prompt, **kwargs):
        # This is just a mock implementation
        return f"This is a simulated response that would analyze the prompt:\n{prompt[:100]}..."
    
    @property
    def _llm_type(self):
        return "mock"

# Create tools for the agent
tools = [CryptoOHLCVTool()]

# Create the agent
llm = MockLLM()
agent = MCPAgent(llm=llm, tools=tools)

# Example query
query = "Analyze the recent price movement of BTC/USDT and suggest possible trading strategies"

# In a real implementation, this would connect to the LLM and use the tools
print("Example agent query:")
print(query)

print("\nSimulated agent execution:")
print("Thought: I need to fetch recent BTC/USDT price data")
print("Action: crypto_ohlcv")
print("Action Input: BTC/USDT, 1d, 30")
print("Observation: [Price data would be shown here]")
print("Thought: Based on this data, I can see several patterns...")
print("Final Answer: Based on my analysis of recent BTC/USDT price movements, I recommend...")

# Note: In an actual implementation, you would run:
# result = agent.run(query)
# print(result)
```

## Configuration for Different Network Environments

Since your setup already includes China/Global mode configurations, we need to ensure the RAG and agent components work in both environments.

Update `.devcontainer/mcp/mcp-setup.zsh` to include:

```bash
# RAG and Agent environment variables
export RAG_DATA_DIR=/workspace/mcp/rag/data
export AGENT_CONFIG_DIR=/workspace/mcp/agent/configs

# Setup alternate mirrors for models based on network environment
if ping -c 1 -W 2 ghproxy.com &> /dev/null; then
  echo "Setting up HuggingFace mirrors for China..."
  export HF_ENDPOINT=https://hf-mirror.com
else
  # Use default endpoints
  unset HF_ENDPOINT
fi
```

## Conclusion

This approach integrates RAG and agent capabilities directly into your MCP environment without requiring changes to your devcontainer setup. It maintains compatibility with your existing workflow while adding powerful new features.

You can begin implementing and testing these components incrementally, starting with basic functionality and expanding as needed.