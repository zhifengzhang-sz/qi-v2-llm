#!/usr/bin/env python3
# Test script for Qwen3-235B-A22B model

import os
import requests
import argparse
import json

def test_qwen3_235b(api_key, api_base="https://dashscope.aliyuncs.com/api/v1"):
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "qwen3-235b-a22b",
        "input": {
            "messages": [{
                "role": "user",
                "content": "Explain quantum computing in 50 words"
            }]
        },
        "parameters": {
            "temperature": 0.7,
            "top_p": 0.9,
            "max_tokens": 500
        }
    }
    
    try:
        response = requests.post(
            f"{api_base}/services/aigc/text-generation/generation",
            headers=headers,
            json=payload
        )
        return response.json()
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--api-key", required=True)
    parser.add_argument("--api-base")
    args = parser.parse_args()
    
    result = test_qwen3_235b(args.api_key, args.api_base)
    print(json.dumps(result, indent=2)) 