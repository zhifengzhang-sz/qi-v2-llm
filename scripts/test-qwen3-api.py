#!/usr/bin/env python3
# Test script for DashScope API (Qwen3)

import os
import sys
import json
import argparse
import requests
from datetime import datetime

# ANSI colors
BLUE = '\033[94m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
RED = '\033[91m'
ENDC = '\033[0m'

def parse_args():
    parser = argparse.ArgumentParser(description='Test DashScope API connection for Qwen3')
    parser.add_argument('--api-key', type=str, help='DashScope API key (default: from environment)')
    parser.add_argument('--api-base', type=str, default='https://dashscope.aliyuncs.com/v1', 
                        help='DashScope API base URL')
    parser.add_argument('--model', type=str, default='qwen3-72b-chat', 
                        help='Qwen3 model to use for testing')
    parser.add_argument('--verbose', action='store_true', help='Display detailed information')
    return parser.parse_args()

def print_status(message, status='info'):
    """Print a status message with appropriate color."""
    if status == 'info':
        print(f"{BLUE}{message}{ENDC}")
    elif status == 'success':
        print(f"{GREEN}{message}{ENDC}")
    elif status == 'warning':
        print(f"{YELLOW}{message}{ENDC}")
    elif status == 'error':
        print(f"{RED}{message}{ENDC}")
    else:
        print(message)

def test_api_connection(api_key, api_base, model, verbose=False):
    """Test the DashScope API connection with a simple query."""
    print_status(f"Testing DashScope API connection with model: {model}", 'info')
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": model,
        "input": {
            "messages": [
                {"role": "user", "content": "Say hello in 5 words or less."}
            ]
        },
        "parameters": {
            "temperature": 0.7,
            "max_tokens": 50
        }
    }
    
    try:
        # Adjust endpoint based on the model and API
        url = f"{api_base.rstrip('/')}/chat/completions"
        if verbose:
            print_status(f"Request URL: {url}", 'info')
            print_status(f"Request data: {json.dumps(data, indent=2)}", 'info')
        
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        if verbose:
            print_status(f"Response status: {response.status_code}", 'info')
            print_status(f"Response content: {response.text}", 'info')
        
        if response.status_code == 200:
            result = response.json()
            if 'output' in result and 'choices' in result['output']:
                message = result['output']['choices'][0]['message']
                content = message.get('content', '')
                print_status(f"API Response: {content}", 'success')
                return True
            else:
                print_status("Unexpected response format", 'error')
                if verbose:
                    print_status(f"Response: {json.dumps(result, indent=2)}", 'info')
                return False
        elif response.status_code == 401:
            print_status("Authentication failed: Invalid API key", 'error')
            return False
        elif response.status_code == 429:
            print_status("Rate limit exceeded: Too many requests", 'warning')
            return False
        else:
            print_status(f"API request failed with status code {response.status_code}", 'error')
            if response.text:
                print_status(f"Error details: {response.text}", 'error')
            return False
    
    except requests.exceptions.RequestException as e:
        print_status(f"Request error: {str(e)}", 'error')
        return False
    except json.JSONDecodeError:
        print_status("Failed to parse API response", 'error')
        print_status(f"Raw response: {response.text}", 'error')
        return False
    except Exception as e:
        print_status(f"Unexpected error: {str(e)}", 'error')
        return False

def main():
    """Main function to test the DashScope API."""
    args = parse_args()
    
    # Get API key from arguments or environment
    api_key = args.api_key or os.environ.get('DASHSCOPE_API_KEY')
    
    if not api_key:
        print_status("No API key provided. Set DASHSCOPE_API_KEY environment variable or use --api-key", 'error')
        sys.exit(1)
    
    success = test_api_connection(api_key, args.api_base, args.model, args.verbose)
    
    if success:
        print_status("\nAPI connection test successful! ✓", 'success')
        sys.exit(0)
    else:
        print_status("\nAPI connection test failed. ✗", 'error')
        sys.exit(1)

if __name__ == "__main__":
    main() 