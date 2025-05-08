#!/bin/bash
# Setup script for RAG and Agent components within the MCP container

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up RAG (Retrieval-Augmented Generation) and Agent components for the MCP environment...${NC}"

# Detect network environment
if ping -c 1 -W 2 ghproxy.com &> /dev/null; then
  echo -e "${YELLOW}Detected China network, using compatible mirrors...${NC}"
  CHINA_MODE=true
  HF_ENDPOINT="https://hf-mirror.com"
  PIP_INDEX="https://pypi.tuna.tsinghua.edu.cn/simple/"
else
  echo -e "${YELLOW}Using global network settings...${NC}"
  CHINA_MODE=false
  HF_ENDPOINT=""
  PIP_INDEX=""
fi

# Install dependencies
echo -e "${YELLOW}Installing required packages...${NC}"

# Configure pip for the appropriate network environment
if [ "$CHINA_MODE" = true ]; then
  pip config set global.index-url $PIP_INDEX
  export HF_ENDPOINT=$HF_ENDPOINT
  echo -e "${GREEN}Configured for China network.${NC}"
fi

# Install RAG dependencies
echo -e "${YELLOW}Installing RAG dependencies...${NC}"
pip install langchain chromadb sentence-transformers faiss-cpu tiktoken pymupdf

# Install agent dependencies
echo -e "${YELLOW}Installing agent dependencies...${NC}"
pip install langchain-experimental guidance openai-function-call

# Install crypto data dependencies
echo -e "${YELLOW}Installing crypto data dependencies...${NC}"
pip install ccxt pandas-ta pycoingecko cryptofeed websocket-client

# Create the directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"

# Create RAG directories
mkdir -p /workspace/mcp/rag/data/crypto/{raw,processed}
mkdir -p /workspace/mcp/rag/data/embeddings
mkdir -p /workspace/mcp/rag/src/{connectors,indexers,retrievers,utils}
mkdir -p /workspace/mcp/rag/examples

# Create agent directories
mkdir -p /workspace/mcp/agent/src/{tools,workflows,memory,models}
mkdir -p /workspace/mcp/agent/examples
mkdir -p /workspace/mcp/agent/configs

# Initialize example files
echo -e "${YELLOW}Creating starter files...${NC}"

# Create RAG utility files
cat > /workspace/mcp/rag/src/utils/vector_store.py << 'EOF'
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
EOF

# Create RAG connector file
cat > /workspace/mcp/rag/src/connectors/crypto_connector.py << 'EOF'
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
EOF

# Create basic agent implementation
cat > /workspace/mcp/agent/src/models/base_agent.py << 'EOF'
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
EOF

# Create agent tool implementation
cat > /workspace/mcp/agent/src/tools/crypto_tools.py << 'EOF'
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
EOF

# Create example RAG notebook
cat > /workspace/mcp/rag/examples/crypto_rag_example.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Cryptocurrency RAG System Example\n",
    "\n",
    "This notebook demonstrates how to use the RAG system with cryptocurrency data."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import sys\n",
    "sys.path.append(\"/workspace/mcp\")\n",
    "\n",
    "from rag.src.utils.vector_store import get_vector_store\n",
    "from rag.src.connectors.crypto_connector import CryptoDataConnector\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Initialize a crypto data connector\n",
    "connector = CryptoDataConnector()\n",
    "\n",
    "# Fetch some BTC data\n",
    "btc_data = connector.get_ohlcv(\"BTC/USDT\", \"1d\", 100)\n",
    "\n",
    "# Display the data\n",
    "print(\"Bitcoin OHLCV Data:\")\n",
    "btc_data.head()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Plot the close price\n",
    "plt.figure(figsize=(12, 6))\n",
    "btc_data['close'].plot()\n",
    "plt.title('Bitcoin Close Price')\n",
    "plt.xlabel('Date')\n",
    "plt.ylabel('Price (USDT)')\n",
    "plt.grid(True)\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Example of RAG in Action\n",
    "\n",
    "In a real implementation, you would:\n",
    "1. Collect news articles, analysis, etc.\n",
    "2. Process and embed them\n",
    "3. Store in the vector database\n",
    "4. Retrieve relevant information based on queries"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# For demonstration, simulate a RAG query\n",
    "print(\"Example of RAG query (simulated):\")\n",
    "print(\"Query: 'What factors affected Bitcoin price in the last week?'\")\n",
    "print(\"\\nRetrieved context (simulated):\")\n",
    "print(\"1. Federal Reserve announced interest rate changes on [date]\")\n",
    "print(\"2. Major institutional investor purchased $X million in BTC on [date]\")\n",
    "print(\"3. Regulatory news from [country] affected market sentiment\")\n",
    "\n",
    "print(\"\\nRAG-enhanced response (simulated):\")\n",
    "print(\"Based on recent market data, Bitcoin price was affected by several factors:\")\n",
    "print(\"1. The Federal Reserve's interest rate announcement led to a price drop of X%\")\n",
    "print(\"2. Following the institutional purchase, there was a price recovery of Y%\")\n",
    "print(\"3. The overall trend remains [bullish/bearish] based on technical indicators\")"
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
   "version": "3.10.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Create example agent notebook
cat > /workspace/mcp/agent/examples/crypto_agent_example.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Cryptocurrency Agent Example\n",
    "\n",
    "This notebook demonstrates how to use the agent system for cryptocurrency analysis."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import sys\n",
    "sys.path.append(\"/workspace/mcp\")\n",
    "\n",
    "from agent.src.models.base_agent import MCPAgent\n",
    "from agent.src.tools.crypto_tools import CryptoOHLCVTool\n",
    "from langchain_core.language_models import LLM\n",
    "import os"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# This is a placeholder for the real implementation\n",
    "# You would use DeepSeek, OpenAI, or another model\n",
    "class MockLLM(LLM):\n",
    "    def _call(self, prompt, **kwargs):\n",
    "        # This is just a mock implementation\n",
    "        return f\"This is a simulated response that would analyze the prompt:\\n{prompt[:100]}...\"\n",
    "    \n",
    "    @property\n",
    "    def _llm_type(self):\n",
    "        return \"mock\""
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create tools for the agent\n",
    "tools = [CryptoOHLCVTool()]\n",
    "\n",
    "# Create the agent\n",
    "llm = MockLLM()\n",
    "agent = MCPAgent(llm=llm, tools=tools)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Example query\n",
    "query = \"Analyze the recent price movement of BTC/USDT and suggest possible trading strategies\"\n",
    "\n",
    "# In a real implementation, this would connect to the LLM and use the tools\n",
    "print(\"Example agent query:\")\n",
    "print(query)\n",
    "\n",
    "print(\"\\nSimulated agent execution:\")\n",
    "print(\"Thought: I need to fetch recent BTC/USDT price data\")\n",
    "print(\"Action: crypto_ohlcv\")\n",
    "print(\"Action Input: BTC/USDT, 1d, 30\")\n",
    "print(\"Observation: [Price data would be shown here]\")\n",
    "print(\"Thought: Based on this data, I can see several patterns...\")\n",
    "print(\"Final Answer: Based on my analysis of recent BTC/USDT price movements, I recommend...\")\n",
    "\n",
    "# Note: In an actual implementation, you would uncomment:\n",
    "# result = agent.run(query)\n",
    "# print(result)"
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
   "version": "3.10.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Create a README file for the components
cat > /workspace/mcp/README_RAG_AGENT.md << 'EOF'
# RAG and Agent Components for MCP

This document provides an overview of the RAG (Retrieval-Augmented Generation) and Agent components installed in this MCP environment.

## Directory Structure

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

## Getting Started

### RAG Components

The RAG system provides retrieval-augmented generation for cryptocurrency market data. It combines:

1. **Data Connectors**: For retrieving market data from exchanges, news sources, etc.
2. **Vector Database**: For storing and retrieving relevant context
3. **Retrieval Mechanisms**: For finding the most relevant information

To get started with RAG:

1. Check out the example notebook: `/workspace/mcp/rag/examples/crypto_rag_example.ipynb`
2. Explore the connector API: `/workspace/mcp/rag/src/connectors/crypto_connector.py`
3. See how vector stores are used: `/workspace/mcp/rag/src/utils/vector_store.py`

### Agent Components

The agent system allows for autonomous execution of complex tasks using:

1. **Tools**: Components that agents can use to interact with data and APIs
2. **Workflows**: Predefined sequences of operations
3. **Agent Models**: Different approaches to agent reasoning

To get started with Agents:

1. Check out the example notebook: `/workspace/mcp/agent/examples/crypto_agent_example.ipynb`
2. Explore tool implementations: `/workspace/mcp/agent/src/tools/crypto_tools.py`
3. See the agent model: `/workspace/mcp/agent/src/models/base_agent.py`

## Using with DeepSeek or Other AI Providers

To use these components with DeepSeek or other AI providers:

1. Configure your API key (if you haven't already):
   ```
   npm run secrets:setup-deepseek
   ```

2. Restart your container to apply the configuration:
   ```
   npm run stop
   npm run start
   ```

3. Update the agent implementation to use your preferred model.

## Further Development

This installation includes starter components that you can extend:

1. Create additional data connectors for other crypto data sources
2. Implement more sophisticated retrieval mechanisms
3. Create specialized agents for different tasks
4. Build custom tools for your specific use cases

For more information, consult the full documentation at `/workspace/mcp/docs/guides/rag-agent-mcp-integration-guide.md`.
EOF

# Create a launcher file
cat > /workspace/mcp/launch-rag-agent.sh << 'EOF'
#!/bin/bash

# Check if Jupyter is already running
if pgrep -f "jupyter" > /dev/null; then
  echo "Jupyter is already running. Opening browser..."
  jupyter lab list
else
  # Start Jupyter Lab with RAG and Agent directories
  jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --notebook-dir=/workspace/mcp
fi
EOF
chmod +x /workspace/mcp/launch-rag-agent.sh

# Add an init.py files for Python package structure
touch /workspace/mcp/rag/__init__.py
touch /workspace/mcp/rag/src/__init__.py
touch /workspace/mcp/rag/src/utils/__init__.py
touch /workspace/mcp/rag/src/connectors/__init__.py
touch /workspace/mcp/agent/__init__.py
touch /workspace/mcp/agent/src/__init__.py
touch /workspace/mcp/agent/src/tools/__init__.py
touch /workspace/mcp/agent/src/models/__init__.py

# Create setup environment script
cat > /workspace/mcp/setup-rag-agent-env.sh << 'EOF'
#!/bin/bash

# Environment variables for RAG and Agent components
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

# Add to PATH if needed
export PATH=$PATH:/workspace/mcp/agent/src/tools

echo "RAG and Agent environment variables set. You can now run the examples."
EOF
chmod +x /workspace/mcp/setup-rag-agent-env.sh

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}To get started:${NC}"
echo -e "1. Source the environment variables: ${GREEN}source /workspace/mcp/setup-rag-agent-env.sh${NC}"
echo -e "2. Launch Jupyter Lab: ${GREEN}/workspace/mcp/launch-rag-agent.sh${NC}"
echo -e "3. Open the example notebooks in the rag/examples and agent/examples directories"
echo -e "4. Read the documentation in ${GREEN}/workspace/mcp/README_RAG_AGENT.md${NC}"

exit 0