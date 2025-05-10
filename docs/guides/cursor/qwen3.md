# Cursor + Qwen3 Integration Guide (2025)

This guide provides step-by-step instructions for setting up and using Cursor with Qwen3 AI models in your development workflow.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Setting Up Your Environment](#setting-up-your-environment)
4. [Method 1: Using Alibaba's DashScope API](#method-1-using-alibabas-dashscope-api)
5. [Method 2: Using OpenRouter](#method-2-using-openrouter)
6. [Switching Between Models](#switching-between-models)
7. [Troubleshooting](#troubleshooting)

## Introduction

Qwen3 is Alibaba's third-generation large language model series. This guide focuses on integrating the advanced `qwen3-235b-a22b` model with Cursor to enhance your development workflow with powerful AI capabilities.

## Prerequisites

Before you begin, ensure you have:

- [Cursor](https://cursor.sh/) installed on your system
- For DashScope method: A DashScope account with access to the `qwen3-235b-a22b` model (requires enterprise plan)
- The QI development environment cloned from the repository
- Docker and Docker Compose installed (for local testing)

## Setting Up Your Environment

First, set up the QI development environment:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/zhifengzhang-sz/qi-v2-llm.git
cd qi-v2-llm

# Install dependencies
npm run setup
```

## Method 1: Using Alibaba's DashScope API

### 1. Configure Your DashScope API Key

Run the setup script to configure your DashScope API key:

```bash
npm run secrets:setup-qwen3
```

This script will:
- Prompt you for your DashScope API key
- Ask for the API base URL (default: `https://dashscope.aliyuncs.com/api/v1`)
- Ask for your preferred model (default: `qwen3-235b-a22b`)
- Save the configuration to your environment

### 2. Test Your Configuration

Verify that your DashScope API key is working correctly:

```bash
# First load the environment variables
source ~/.dashscope.env

# Verify variables are set
echo "API Key: ${DASHSCOPE_API_KEY:0:6}..."
echo "API Base: $DASHSCOPE_API_BASE"
echo "Default Model: $DASHSCOPE_DEFAULT_MODEL"

# Run the test
npm run test:qwen3-235b
```

### 3. Configure Cursor to Use qwen3-235b-a22b

1. Open Cursor settings (File > Preferences > Settings)
2. Click on "Extensions" in the left sidebar
3. Select "Cursor" from the extensions list
4. In the "AI Model Configuration" section:
   - Click "+ Add model"
   - Set "New model name" to `qwen3-235b-a22b`
   - Set "OpenAI API Key" to your DashScope API key
   - Set "Override OpenAI Base URL" to `https://dashscope.aliyuncs.com/api/v1`
   - Click "Verify" to test the connection
   - Click "Save" to apply the settings

## Method 2: Using OpenRouter

OpenRouter provides access to various AI models, including some Qwen3 variants, through a unified API.

### 1. Create an OpenRouter Account

1. Go to [OpenRouter](https://openrouter.ai)
2. Create an account and generate an API key
3. Make sure you have credits available

### 2. Configure Cursor to Use Qwen3 via OpenRouter

1. Open Cursor settings (File > Preferences > Settings)
2. Click on "Extensions" in the left sidebar
3. Select "Cursor" from the extensions list
4. In the "AI Model Configuration" section:
   - Click "+ Add model"
   - Set "New model name" to `qwen/qwen3-72b-chat` (or other supported Qwen3 variant)
   - Set "OpenAI API Key" to your OpenRouter API key (starts with `sk-or-v1-`)
   - Set "Override OpenAI Base URL" to `https://openrouter.ai/api/v1`
   - Click "Verify" to test the connection
   - Click "Save" to apply the settings

### 3. Testing the OpenRouter Integration

To verify your OpenRouter API key is working, you can run this command in your terminal:

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_OPENROUTER_API_KEY" \
  -d '{
    "model": "qwen/qwen3-72b-chat",
    "messages": [
      {"role": "user", "content": "Say hello in 5 words or less."}
    ]
  }'
```

Replace `YOUR_OPENROUTER_API_KEY` with your actual OpenRouter API key.

## Switching Between Models

Cursor allows you to configure multiple AI models and switch between them:

1. Click on the AI model name in the bottom right corner of Cursor
2. Select the model you want to use from the dropdown menu

This flexibility allows you to choose between:
- DeepSeek for some tasks
- Qwen3 for others
- Any other configured models

## Troubleshooting

### API Connection Issues

If you encounter connection issues:

1. **Verify your API key**:
   - Ensure your key has access to the `qwen3-235b-a22b` model (requires enterprise tier)
   - Check expiration date
   - Make sure environment variables are sourced (`source ~/.dashscope.env`)

2. **Confirm base URL**:
   - Must use `https://dashscope.aliyuncs.com/api/v1` for Qwen3 models

3. **Model availability**:
   - Confirm your account has been granted access to the `qwen3-235b-a22b` model
   - Check model activation status in the DashScope console
   - Contact Alibaba Cloud support if you need access

### Common Errors

**1. Missing API Base URL**
```bash
usage: test-qwen3-235b-api.py [-h] --api-key API_KEY [--api-base API_BASE]
test-qwen3-235b-api.py: error: argument --api-base: expected one argument
```
**Solution:**
- Ensure you've sourced the environment: `source ~/.dashscope.env`
- Verify setup script ran successfully
- Check for typos in environment variables

**2. Model Not Found**
```json
{
  "error": {
    "message": "The model `qwen3-235b-a22b` does not exist or you do not have access to it.",
    "type": "invalid_request_error",
    ...
}
```
**Solution:**
- Confirm model activation in DashScope console
- Use `qwen3-72b-chat` for standard accounts
- Contact Alibaba Cloud support for enterprise access

### Model-Specific Considerations

For `qwen3-235b-a22b`:
- Requires enterprise-level DashScope plan
- High computational requirements (latency ~2-5s)
- Max context window: 32,768 tokens
- Ideal for complex code generation and multi-step reasoning
- Use temperature 0.7-1.0 for creative tasks
- Use temperature 0.1-0.3 for factual responses

### Cursor Configuration

If Cursor isn't using your configured model:

1. Make sure you've selected the correct model from the dropdown
2. Try disabling other API keys that might be taking precedence
3. Restart Cursor after making configuration changes

For more help, visit the [Cursor Forum](https://forum.cursor.com/) or [Alibaba Cloud Support](https://www.alibabacloud.com/help).

### Understanding the `~/.dashscope.env` File

The `~/.dashscope.env` file is created by the setup script to store your Qwen3 configuration securely. It contains:

```bash
# ~/.dashscope.env
export DASHSCOPE_API_KEY="your-api-key-here"
export DASHSCOPE_API_BASE="https://dashscope.aliyuncs.com/api/v1"
export DASHSCOPE_DEFAULT_MODEL="qwen3-235b-a22b"
```

**Key Operations:**

1. **Automatic Creation**
```bash
# Created automatically during setup
npm run secrets:setup-qwen3
# File permissions set to 600 for security
ls -l ~/.dashscope.env
```

2. **Manual Verification**
```bash
# Check file contents
cat ~/.dashscope.env

# Expected output format:
export DASHSCOPE_API_KEY="sk-..."
export DASHSCOPE_API_BASE="https://dashscope.aliyuncs.com/api/v1"
export DASHSCOPE_DEFAULT_MODEL="qwen3-235b-a22b"
```

3. **Environment Loading**
```bash
# Required for each new terminal session
source ~/.dashscope.env

# Verify variables are loaded
echo $DASHSCOPE_API_KEY    # Should show key (truncated)
echo $DASHSCOPE_API_BASE   # Should show API base URL
echo $DASHSCOPE_DEFAULT_MODEL  # Should show model name
```

4. **File Management**
```bash
# Remove sensitive data (when needed)
unset DASHSCOPE_API_KEY

# Backup configuration
cp ~/.dashscope.env ~/.dashscope.env.bak

# Restore from backup
cp ~/.dashscope.env.bak ~/.dashscope.env
source ~/.dashscope.env
```

**Common Issues:**

**1. Missing File After Setup**
```bash
# Solution: Check setup script execution
ls -la ~/.dashscope* 
# If missing, rerun setup:
npm run secrets:setup-qwen3
```

**2. Partial Configuration**
```bash
# If only some variables are set:
grep -v "^#" ~/.dashscope.env | wc -l
# Should return 3 lines of exports
```

**3. Environment Not Persisting**
```bash
# Add to shell config for permanent access
echo 'source ~/.dashscope.env' >> ~/.zshrc
source ~/.zshrc
```

This section clarifies the purpose and management of the `~/.dashscope.env` file, helping users understand:
- What the file contains
- How it's created and maintained
- How to verify its contents
- Common troubleshooting steps
- Best practices for security and persistence
