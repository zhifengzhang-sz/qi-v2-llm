#!/bin/bash
#
# DeepSeek API Setup Script
# This script helps configure DeepSeek API credentials and performs basic setup tests
#

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration paths
CONFIG_DIR="$HOME/.config/deepseek"
CONFIG_FILE="$CONFIG_DIR/config.json"
ENV_FILE="$HOME/.deepseek.env"

# Check if test-deepseek-api.py exists in the same directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_SCRIPT="$SCRIPT_DIR/test-deepseek-api.py"

if [ ! -f "$TEST_SCRIPT" ]; then
    echo -e "${RED}Error: test-deepseek-api.py not found in the same directory${NC}"
    echo "Make sure both scripts are in the same location"
    exit 1
fi

# Ensure configuration directory exists
mkdir -p "$CONFIG_DIR"

# Banner
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}         DeepSeek API Setup Tool           ${NC}"
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
# DeepSeek API Configuration
export DEEPSEEK_API_KEY="$api_key"
export DEEPSEEK_API_BASE="$api_base"
export DEEPSEEK_DEFAULT_MODEL="$model"
EOF
    chmod 600 "$ENV_FILE"
    
    echo -e "${GREEN}Configuration saved to:${NC}"
    echo "  - $CONFIG_FILE"
    echo "  - $ENV_FILE"
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
                MODEL=$(jq -r '.default_model // "deepseek-chat"' "$CONFIG_FILE")
            else
                API_KEY=$(grep -o '"api_key": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
                API_BASE=$(grep -o '"api_base": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
                MODEL=$(grep -o '"default_model": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 || echo "deepseek-chat")
            fi
            
            echo -e "${BLUE}Using existing configuration:${NC}"
            echo "  API Base: $API_BASE"
            echo "  Default Model: $MODEL"
            echo ""
        fi
    else
        # Create new configuration
        echo -e "${BLUE}Creating new DeepSeek API configuration${NC}"
        echo ""
    fi
else
    echo -e "${BLUE}No existing configuration found. Let's set up DeepSeek API.${NC}"
    echo ""
fi

# Ask for API key if not loaded from config
if [ -z "$API_KEY" ]; then
    read -p "Enter your DeepSeek API key: " API_KEY
    while [ -z "$API_KEY" ]; do
        echo -e "${RED}API key cannot be empty.${NC}"
        read -p "Enter your DeepSeek API key: " API_KEY
    done
fi

# Ask for API base URL with default
if [ -z "$API_BASE" ]; then
    read -p "Enter DeepSeek API base URL [https://api.deepseek.com]: " API_BASE
    API_BASE=${API_BASE:-"https://api.deepseek.com"}
fi

# Ask for default model with default
if [ -z "$MODEL" ]; then
    read -p "Enter default model [deepseek-chat]: " MODEL
    MODEL=${MODEL:-"deepseek-chat"}
fi

# Save configuration
save_config "$API_KEY" "$API_BASE" "$MODEL"

# Test connection
echo -e "${BLUE}Testing DeepSeek API connection...${NC}"
echo ""

export DEEPSEEK_API_KEY="$API_KEY"
if python3 "$TEST_SCRIPT" --api-base "$API_BASE" --model "$MODEL" --skip-rate-limits; then
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo ""
    echo -e "${YELLOW}To use DeepSeek API in your scripts:${NC}"
    echo "1. Load environment variables:"
    echo "   source $ENV_FILE"
    echo ""
    echo "2. Access the API key in your scripts:"
    echo "   Python: os.environ.get('DEEPSEEK_API_KEY')"
    echo "   Bash: \$DEEPSEEK_API_KEY"
    echo ""
    echo -e "${YELLOW}For more comprehensive testing:${NC}"
    echo "   $TEST_SCRIPT --verbose"
    echo ""
else
    echo ""
    echo -e "${RED}API connection test failed.${NC}"
    echo "Please check your API key and network connection, then try again."
    echo ""
fi