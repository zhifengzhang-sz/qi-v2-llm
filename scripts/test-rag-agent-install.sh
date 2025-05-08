#!/bin/bash
# Test script for the RAG and Agent installation process

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing RAG and Agent installation script...${NC}"

# Check if running inside container
if [ ! -d "/workspace/mcp" ]; then
  echo -e "${RED}Error: This test must be run inside the MCP container.${NC}"
  echo "Please run 'npm run mcp' first, then execute this test script."
  exit 1
fi

# Create test directory
TEST_DIR="/workspace/mcp/test-rag-agent"
mkdir -p $TEST_DIR

# Function to check if packages are installed
check_packages() {
  echo -e "${YELLOW}Checking for required packages...${NC}"
  
  PACKAGES=("langchain" "chromadb" "sentence-transformers" "faiss-cpu" "ccxt")
  MISSING=0
  
  for pkg in "${PACKAGES[@]}"; do
    if python -c "import $pkg" 2>/dev/null; then
      echo -e "  ${GREEN}✓ $pkg${NC}"
    else
      echo -e "  ${RED}✗ $pkg${NC}"
      MISSING=$((MISSING+1))
    fi
  done
  
  return $MISSING
}

# Function to test cryptocurrency API connectivity
test_crypto_api() {
  echo -e "${YELLOW}Testing cryptocurrency API connectivity...${NC}"
  
  cat > $TEST_DIR/test_crypto.py << 'EOF'
import ccxt
import sys

try:
    # Initialize the exchange (without API keys for public data)
    binance = ccxt.binance({'enableRateLimit': True})
    
    # Fetch BTC/USDT ticker as a basic test
    ticker = binance.fetch_ticker('BTC/USDT')
    
    # If we get a price, the API is working
    if 'last' in ticker and ticker['last'] > 0:
        print(f"Success! Current BTC price: {ticker['last']} USDT")
        sys.exit(0)
    else:
        print("Error: Could not get valid price data")
        sys.exit(1)
except Exception as e:
    print(f"Error connecting to cryptocurrency API: {str(e)}")
    sys.exit(1)
EOF

  python $TEST_DIR/test_crypto.py
  return $?
}

# Function to test RAG functionality
test_rag_functionality() {
  echo -e "${YELLOW}Testing basic RAG functionality...${NC}"
  
  cat > $TEST_DIR/test_rag.py << 'EOF'
import sys
from langchain.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings

try:
    # Initialize the embedding model
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    
    # Create a simple vector store
    texts = [
        "Bitcoin is a cryptocurrency invented by Satoshi Nakamoto",
        "Ethereum introduces smart contracts to blockchain",
        "Quantitative investment strategies use mathematical models",
        "Technical analysis uses historical price data for trading decisions"
    ]
    
    # Create a vector store
    vectorstore = Chroma.from_texts(
        texts=texts,
        embedding=embeddings,
        persist_directory="/workspace/mcp/test-rag-agent/vector_db"
    )
    
    # Test similarity search
    results = vectorstore.similarity_search("digital currency blockchain", k=2)
    
    if len(results) == 2:
        print("RAG vector store successfully created and queried")
        print(f"Top result: {results[0].page_content}")
        sys.exit(0)
    else:
        print("Error: Vector store query didn't return expected results")
        sys.exit(1)
except Exception as e:
    print(f"Error testing RAG functionality: {str(e)}")
    sys.exit(1)
EOF

  python $TEST_DIR/test_rag.py
  return $?
}

# Main test sequence
echo -e "${YELLOW}Step 1: Running the installation script...${NC}"
/workspace/mcp/install-rag-agent.sh

# Check the return code of the installation
if [ $? -ne 0 ]; then
  echo -e "${RED}Installation script failed.${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 2: Sourcing the environment...${NC}"
source /workspace/mcp/setup-rag-agent-env.sh

echo -e "${YELLOW}Step 3: Checking package installations...${NC}"
check_packages
if [ $? -ne 0 ]; then
  echo -e "${RED}One or more required packages are missing.${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 4: Testing cryptocurrency API connectivity...${NC}"
test_crypto_api
if [ $? -ne 0 ]; then
  echo -e "${RED}Cryptocurrency API connectivity test failed.${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 5: Testing RAG functionality...${NC}"
test_rag_functionality
if [ $? -ne 0 ]; then
  echo -e "${RED}RAG functionality test failed.${NC}"
  exit 1
fi

# Verify directory structure
echo -e "${YELLOW}Step 6: Verifying directory structure...${NC}"
DIRECTORIES=(
  "/workspace/mcp/rag/data/crypto/raw"
  "/workspace/mcp/rag/data/embeddings"
  "/workspace/mcp/rag/src/connectors"
  "/workspace/mcp/rag/examples"
  "/workspace/mcp/agent/src/tools"
  "/workspace/mcp/agent/examples"
)

for dir in "${DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo -e "  ${GREEN}✓ $dir${NC}"
  else
    echo -e "  ${RED}✗ $dir${NC}"
    echo -e "${RED}Directory structure verification failed.${NC}"
    exit 1
  fi
done

# Check for example notebooks
if [ -f "/workspace/mcp/rag/examples/crypto_rag_example.ipynb" ] && [ -f "/workspace/mcp/agent/examples/crypto_agent_example.ipynb" ]; then
  echo -e "${GREEN}Example notebooks are present.${NC}"
else
  echo -e "${RED}Example notebooks are missing.${NC}"
  exit 1
fi

# Clean up test directory
rm -rf $TEST_DIR

echo -e "${GREEN}All tests passed successfully!${NC}"
echo -e "${GREEN}The RAG and Agent installation is working correctly.${NC}"
exit 0