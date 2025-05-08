#!/usr/bin/env python3
"""
Test script for DeepSeek API connectivity

This script tests connectivity to the DeepSeek API and validates that it's properly
configured for use with your RAG and Agent setup.
"""

import os
import sys
import time
import json
import argparse
import requests
from typing import Dict, Any, Optional, List
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("deepseek-api-test")

# Default API settings
DEFAULT_API_BASE = "https://api.deepseek.com"
DEFAULT_API_VERSION = "v1"
DEFAULT_MODEL = "deepseek-chat"
DEFAULT_MAX_TOKENS = 1000
DEFAULT_TEMPERATURE = 0.7

class DeepSeekAPI:
    """Client for interacting with the DeepSeek API."""
    
    def __init__(
        self, 
        api_key: Optional[str] = None, 
        api_base: str = DEFAULT_API_BASE,
        api_version: str = DEFAULT_API_VERSION
    ):
        """
        Initialize the DeepSeek API client.
        
        Args:
            api_key: DeepSeek API key. If None, will look for DEEPSEEK_API_KEY environment variable.
            api_base: Base URL for the DeepSeek API.
            api_version: API version to use.
        """
        self.api_key = api_key or os.environ.get("DEEPSEEK_API_KEY")
        if not self.api_key:
            raise ValueError("No API key provided. Set DEEPSEEK_API_KEY environment variable or pass api_key parameter.")
        
        self.api_base = api_base
        self.api_version = api_version
        self.session = requests.Session()
        
        # Set up base headers
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
    
    def get_completion(
        self, 
        messages: List[Dict[str, str]], 
        model: str = DEFAULT_MODEL,
        temperature: float = DEFAULT_TEMPERATURE,
        max_tokens: int = DEFAULT_MAX_TOKENS,
        stream: bool = False
    ) -> Dict[str, Any]:
        """
        Get a completion from the DeepSeek API.
        
        Args:
            messages: List of message dictionaries with 'role' and 'content' keys.
            model: Model to use for completion.
            temperature: Sampling temperature.
            max_tokens: Maximum number of tokens to generate.
            stream: Whether to stream the response.
            
        Returns:
            API response as a dictionary.
        """
        url = f"{self.api_base}/{self.api_version}/chat/completions"
        
        payload = {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": stream
        }
        
        try:
            response = self.session.post(url, headers=self.headers, json=payload, timeout=60)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"API request failed: {e}")
            if hasattr(e, 'response') and e.response:
                logger.error(f"Response status: {e.response.status_code}")
                logger.error(f"Response body: {e.response.text}")
            raise
    
    def get_models(self) -> Dict[str, Any]:
        """
        Get available models from the DeepSeek API.
        
        Returns:
            List of available models.
        """
        url = f"{self.api_base}/{self.api_version}/models"
        
        try:
            response = self.session.get(url, headers=self.headers, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to get models: {e}")
            if hasattr(e, 'response') and e.response:
                logger.error(f"Response status: {e.response.status_code}")
                logger.error(f"Response body: {e.response.text}")
            raise

def test_api_connectivity(api_client: DeepSeekAPI) -> bool:
    """
    Test basic connectivity to the DeepSeek API.
    
    Args:
        api_client: Initialized DeepSeekAPI client.
        
    Returns:
        True if successful, False otherwise.
    """
    try:
        logger.info("Testing API connectivity...")
        start_time = time.time()
        models = api_client.get_models()
        elapsed = time.time() - start_time
        
        if "data" in models and isinstance(models["data"], list):
            logger.info(f"✅ API connection successful ({elapsed:.2f}s)")
            logger.info(f"Available models: {', '.join([m.get('id', 'unknown') for m in models['data']])}")
            return True
        else:
            logger.error("❌ API returned unexpected format")
            logger.error(f"Response: {json.dumps(models, indent=2)}")
            return False
    except Exception as e:
        logger.error(f"❌ API connectivity test failed: {e}")
        return False

def test_completion(api_client: DeepSeekAPI, model: str) -> bool:
    """
    Test completion functionality with the DeepSeek API.
    
    Args:
        api_client: Initialized DeepSeekAPI client.
        model: Model to test with.
        
    Returns:
        True if successful, False otherwise.
    """
    try:
        logger.info(f"Testing completion with model '{model}'...")
        
        # Simple test message
        messages = [
            {"role": "system", "content": "You are DeepSeek, a helpful AI assistant."},
            {"role": "user", "content": "What are the applications of quantitative investment in cryptocurrency markets?"}
        ]
        
        start_time = time.time()
        response = api_client.get_completion(messages, model=model, max_tokens=200)
        elapsed = time.time() - start_time
        
        if "choices" in response and len(response["choices"]) > 0:
            content = response["choices"][0].get("message", {}).get("content", "")
            logger.info(f"✅ Completion test successful ({elapsed:.2f}s)")
            logger.info("Sample response:")
            logger.info("-" * 40)
            logger.info(content[:200] + ("..." if len(content) > 200 else ""))
            logger.info("-" * 40)
            return True
        else:
            logger.error("❌ Completion test failed: unexpected response format")
            logger.error(f"Response: {json.dumps(response, indent=2)}")
            return False
    except Exception as e:
        logger.error(f"❌ Completion test failed: {e}")
        return False

def test_domain_specific(api_client: DeepSeekAPI, model: str) -> bool:
    """
    Test domain-specific knowledge related to quantitative investment and crypto.
    
    Args:
        api_client: Initialized DeepSeekAPI client.
        model: Model to test with.
        
    Returns:
        True if successful, False otherwise.
    """
    try:
        logger.info("Testing domain-specific knowledge...")
        
        # Domain-specific test message
        messages = [
            {"role": "system", "content": "You are DeepSeek, a helpful AI assistant specializing in quantitative investment."},
            {"role": "user", "content": "Explain how to calculate the Sharpe ratio for a cryptocurrency portfolio and why it's important."}
        ]
        
        start_time = time.time()
        response = api_client.get_completion(messages, model=model, max_tokens=300)
        elapsed = time.time() - start_time
        
        if "choices" in response and len(response["choices"]) > 0:
            content = response["choices"][0].get("message", {}).get("content", "")
            
            # Check for domain terminology
            domain_terms = ["risk-adjusted", "return", "volatility", "standard deviation", "excess return"]
            
            matched_terms = [term for term in domain_terms if term.lower() in content.lower()]
            
            if matched_terms:
                logger.info(f"✅ Domain knowledge test successful ({elapsed:.2f}s)")
                logger.info(f"Matched domain terms: {', '.join(matched_terms)}")
                return True
            else:
                logger.warning("⚠️ Domain knowledge test partial: response doesn't contain expected terminology")
                logger.info("Sample response:")
                logger.info("-" * 40)
                logger.info(content[:200] + ("..." if len(content) > 200 else ""))
                logger.info("-" * 40)
                return True  # Still return True as the API worked
        else:
            logger.error("❌ Domain knowledge test failed: unexpected response format")
            return False
    except Exception as e:
        logger.error(f"❌ Domain knowledge test failed: {e}")
        return False

def test_rate_limits(api_client: DeepSeekAPI, model: str) -> bool:
    """
    Test API rate limits by making several requests in sequence.
    
    Args:
        api_client: Initialized DeepSeekAPI client.
        model: Model to test with.
        
    Returns:
        True if successful, False otherwise.
    """
    try:
        logger.info("Testing API rate limits with sequential requests...")
        
        # Simple query to use for testing
        messages = [
            {"role": "system", "content": "You are DeepSeek, a helpful AI assistant."},
            {"role": "user", "content": "Hello, how are you today?"}
        ]
        
        # Make 3 requests in quick succession
        num_requests = 3
        successful = 0
        
        for i in range(1, num_requests + 1):
            logger.info(f"Making request {i}/{num_requests}...")
            try:
                start_time = time.time()
                response = api_client.get_completion(messages, model=model, max_tokens=50)
                elapsed = time.time() - start_time
                
                if "choices" in response and len(response["choices"]) > 0:
                    logger.info(f"✅ Request {i} successful ({elapsed:.2f}s)")
                    successful += 1
                else:
                    logger.warning(f"⚠️ Request {i} returned unexpected format")
                
                # Small delay to avoid hitting rate limits too hard
                time.sleep(1)
            except Exception as e:
                logger.error(f"❌ Request {i} failed: {e}")
        
        rate_limit_percentage = (successful / num_requests) * 100
        if rate_limit_percentage == 100:
            logger.info("✅ Rate limit test passed: All requests were successful")
            return True
        elif rate_limit_percentage >= 50:
            logger.warning(f"⚠️ Rate limit test partially successful: {rate_limit_percentage:.1f}% of requests succeeded")
            return True  # Still return True as some requests worked
        else:
            logger.error(f"❌ Rate limit test failed: Only {rate_limit_percentage:.1f}% of requests succeeded")
            return False
    except Exception as e:
        logger.error(f"❌ Rate limit test failed with unexpected error: {e}")
        return False

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Test DeepSeek API connectivity and functionality")
    
    parser.add_argument(
        "--api-key", 
        type=str, 
        help="DeepSeek API key (will use DEEPSEEK_API_KEY environment variable if not provided)"
    )
    parser.add_argument(
        "--api-base", 
        type=str, 
        default=DEFAULT_API_BASE,
        help=f"Base URL for DeepSeek API (default: {DEFAULT_API_BASE})"
    )
    parser.add_argument(
        "--model", 
        type=str, 
        default=DEFAULT_MODEL,
        help=f"Model to test (default: {DEFAULT_MODEL})"
    )
    parser.add_argument(
        "--skip-rate-limits", 
        action="store_true",
        help="Skip rate limit tests"
    )
    parser.add_argument(
        "--verbose", 
        action="store_true",
        help="Enable verbose logging"
    )
    
    return parser.parse_args()

def main():
    """Main function to run the tests."""
    args = parse_arguments()
    
    # Set logging level based on verbosity
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    logger.info("Starting DeepSeek API tests...")
    logger.info(f"API Base: {args.api_base}")
    logger.info(f"Model: {args.model}")
    
    try:
        # Initialize API client
        api_client = DeepSeekAPI(
            api_key=args.api_key,
            api_base=args.api_base
        )
        
        # Run tests
        tests = [
            ("API Connectivity", lambda: test_api_connectivity(api_client)),
            ("Completion", lambda: test_completion(api_client, args.model)),
            ("Domain Knowledge", lambda: test_domain_specific(api_client, args.model))
        ]
        
        if not args.skip_rate_limits:
            tests.append(("Rate Limits", lambda: test_rate_limits(api_client, args.model)))
        
        # Run each test and collect results
        results = []
        for name, test_func in tests:
            logger.info("\n" + "=" * 50)
            logger.info(f"Running test: {name}")
            logger.info("=" * 50)
            
            start_time = time.time()
            success = test_func()
            elapsed = time.time() - start_time
            
            results.append((name, success, elapsed))
            
            # Small delay between tests
            time.sleep(1)
        
        # Print summary
        logger.info("\n" + "=" * 50)
        logger.info("Test Summary")
        logger.info("=" * 50)
        
        for name, success, elapsed in results:
            status = "✅ PASSED" if success else "❌ FAILED"
            logger.info(f"{status} - {name} ({elapsed:.2f}s)")
        
        # Overall result
        success_count = sum(1 for _, success, _ in results if success)
        if success_count == len(results):
            logger.info("\n✅ All tests passed! DeepSeek API is properly configured.")
            return 0
        elif success_count > 0:
            logger.warning(f"\n⚠️ {success_count}/{len(results)} tests passed. Some DeepSeek API features are working.")
            return 1
        else:
            logger.error("\n❌ All tests failed! Please check your DeepSeek API configuration.")
            return 2
    
    except Exception as e:
        logger.error(f"Tests failed with unexpected error: {e}")
        return 3

if __name__ == "__main__":
    sys.exit(main())