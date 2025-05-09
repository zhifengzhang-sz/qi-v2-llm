#!/bin/bash
#
# Qwen3 DashScope API Setup Script
# This script helps configure DashScope API credentials for Qwen3 models
#

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration paths
CONFIG_DIR="$HOME/.config/dashscope"
CONFIG_FILE="$CONFIG_DIR/config.json"
ENV_FILE="$HOME/.dashscope.env"

# Check if test-qwen3-api.py exists in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_SCRIPT="$SCRIPT_DIR/test-qwen3-api.py"

if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${RED}Warning: test-qwen3-api.py not found in the same directory${NC}"
    echo "Tests will be skipped. Please create a test script for complete setup."
fi

# Ensure configuration directory exists
mkdir -p "$CONFIG_DIR"

# Banner
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}      DashScope API Setup for Qwen3         ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Helper functions
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}Error: $1 is not installed.${NC}"
        echo "Please install $1 before continuing."
        exit 1
    fi
}

save_config() {
    local api_key="$1"
    local api_base="$2"
    local model="$3"
    
    # Save to JSON config file
    cat > "$CONFIG_FILE" << EOF
{
    "api_key": "$api_key",
    "api_base": "$api_base",
    "default_model": "$model",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    chmod 600 "$CONFIG_FILE"
    
    # Save to env file
    cat > "$ENV_FILE" << EOF
# DashScope API Configuration for Qwen3
export DASHSCOPE_API_KEY="$api_key"
export DASHSCOPE_API_BASE="$api_base"
export DASHSCOPE_DEFAULT_MODEL="$model"
EOF
    chmod 600 "$ENV_FILE"
    
    # Add to .env file in .devcontainer if it exists
    DEVCONTAINER_ENV=".devcontainer/.env"
    if [ -f "$DEVCONTAINER_ENV" ]; then
        if grep -q "DASHSCOPE_API_KEY" "$DEVCONTAINER_ENV"; then
            # Update existing entry
            sed -i "s|DASHSCOPE_API_KEY=.*|DASHSCOPE_API_KEY=\"$api_key\"|g" "$DEVCONTAINER_ENV"
        else
            # Add new entry
            echo "DASHSCOPE_API_KEY=\"$api_key\"" >> "$DEVCONTAINER_ENV"
        fi
        chmod 600 "$DEVCONTAINER_ENV"
    fi
    
    echo -e "${GREEN}Configuration saved to:${NC}"
    echo "  - $CONFIG_FILE"
    echo "  - $ENV_FILE"
    if [ -f "$DEVCONTAINER_ENV" ]; then
        echo "  - $DEVCONTAINER_ENV"
    fi
    echo ""
    echo -e "${YELLOW}To load these settings in your current terminal:${NC}"
    echo "  source $ENV_FILE"
}

# Check required commands
check_command "python3"
check_command "curl"

# Determine if configuration exists
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Existing configuration found at $CONFIG_FILE${NC}"
    echo ""
    read -p "Do you want to create a new configuration? (y/n): " create_new
    
    if [[ "$create_new" != "y" && "$create_new" != "Y" ]]; then
        # Load existing configuration
        if [ -f "$CONFIG_FILE" ]; then
            if command -v "jq" &>/dev/null; then
                API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")
                API_BASE=$(jq -r '.api_base' "$CONFIG_FILE")
                MODEL=$(jq -r '.default_model // "qwen3-72b-chat"' "$CONFIG_FILE")
            else
                API_KEY=$(grep -o '"api_key": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
                API_BASE=$(grep -o '"api_base": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
                MODEL=$(grep -o '"default_model": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 || echo "qwen3-72b-chat")
            fi
            
            echo -e "${BLUE}Using existing configuration:${NC}"
            echo "  API Base: $API_BASE"
            echo "  Default Model: $MODEL"
            echo ""
        fi
    else
        # Create new configuration
        echo -e "${BLUE}Creating new DashScope API configuration${NC}"
        echo ""
    fi
else
    echo -e "${BLUE}No existing configuration found. Let's set up DashScope API.${NC}"
    echo ""
fi

# Ask for API key if not loaded from config
if [ -z "$API_KEY" ]; then
    read -p "Enter your DashScope API key: " API_KEY
    while [ -z "$API_KEY" ]; do
        echo -e "${RED}API key cannot be empty.${NC}"
        read -p "Enter your DashScope API key: " API_KEY
    done
fi

# Ask for API base URL with default
if [ -z "$API_BASE" ]; then
    read -p "Enter DashScope API base URL [https://dashscope.aliyuncs.com/v1]: " API_BASE
    API_BASE=${API_BASE:-"https://dashscope.aliyuncs.com/v1"}
fi

# Ask for default model with default
if [ -z "$MODEL" ]; then
    read -p "Enter default model [qwen3-235b-a22b]: " MODEL
    MODEL=${MODEL:-"qwen3-235b-a22b"}
fi

# Save configuration
save_config "$API_KEY" "$API_BASE" "$MODEL"

# Test connection if test script exists
if [ -f "$TEST_SCRIPT" ]; then
    echo -e "${BLUE}Testing DashScope API connection...${NC}"
    echo ""

    export DASHSCOPE_API_KEY="$API_KEY"
    if python3 "$TEST_SCRIPT" --api-base "$API_BASE" --model "$MODEL"; then
        echo ""
        echo -e "${GREEN}Setup complete!${NC}"
    else
        echo ""
        echo -e "${RED}API connection test failed.${NC}"
        echo "Please check your API key and network connection, then try again."
        echo ""
    fi
else
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${YELLOW}Note: Test script not found. No connection test was performed.${NC}"
fi

echo ""
echo -e "${YELLOW}To use DashScope API in your scripts:${NC}"
echo "1. Load environment variables:"
echo "   source $ENV_FILE"
echo ""
echo "2. Access the API key in your scripts:"
echo "   Python: os.environ.get('DASHSCOPE_API_KEY')"
echo "   Bash: \$DASHSCOPE_API_KEY"
echo "" 