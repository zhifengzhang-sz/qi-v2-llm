#!/bin/bash
# Script to generate sample cryptocurrency data for RAG and Agent examples

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Generating sample cryptocurrency data for RAG and Agent examples...${NC}"

# Check if running inside container
if [ ! -d "/workspace/mcp" ]; then
  echo -e "${RED}Error: This script must be run inside the MCP container.${NC}"
  echo "Please run 'npm run mcp' first, then execute this script."
  exit 1
fi

# Check if RAG directories exist
if [ ! -d "/workspace/mcp/rag/data/crypto/raw" ]; then
  echo -e "${RED}Error: RAG directories not found.${NC}"
  echo "Please run 'install-rag-agent.sh' first, then execute this script."
  exit 1
fi

# Create sample data directories if they don't exist
mkdir -p /workspace/mcp/rag/data/crypto/raw
mkdir -p /workspace/mcp/rag/data/crypto/processed

# Generate Python script to create sample data
cat > /workspace/mcp/rag/data/generate_sample_data.py << 'EOF'
#!/usr/bin/env python3
"""
Generate sample cryptocurrency data for RAG and Agent examples.
"""

import os
import pandas as pd
import numpy as np
import json
from datetime import datetime, timedelta
import random

# Set random seed for reproducibility
np.random.seed(42)

def generate_ohlcv_data(symbol, days=180, volatility=0.02):
    """Generate synthetic OHLCV (Open, High, Low, Close, Volume) data."""
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    # Generate price data with some randomness and trend
    close_prices = []
    price = 100.0  # Starting price
    
    # Add some seasonality and trends
    for i in range(len(dates)):
        # Weekly cycle (higher on weekends)
        day_of_week = dates[i].weekday()
        weekly_factor = 1.0 + (0.01 if day_of_week >= 5 else 0)
        
        # Monthly trend (general upward)
        monthly_factor = 1.0 + (0.001 * (i // 30))
        
        # Add some randomness
        random_change = np.random.normal(0, volatility)
        
        # Calculate new price
        price = price * (1 + random_change) * weekly_factor * monthly_factor
        close_prices.append(price)
    
    # Create price and volume dataframe
    df = pd.DataFrame(index=dates)
    df['close'] = close_prices
    
    # Generate other OHLCV columns based on close price
    df['open'] = df['close'].shift(1).fillna(df['close'] * 0.99)
    daily_volatility = df['close'] * volatility
    df['high'] = df['close'] + daily_volatility * np.random.random(len(df))
    df['low'] = df['close'] - daily_volatility * np.random.random(len(df))
    df['low'] = df[['low', 'open', 'close']].min(axis=1)  # Ensure low is lowest
    df['high'] = df[['high', 'open', 'close']].max(axis=1)  # Ensure high is highest
    
    # Generate volume with some randomness
    base_volume = 1000000  # Base volume
    df['volume'] = base_volume * (1 + np.random.random(len(df)) * 2)
    
    # Add symbol column
    df['symbol'] = symbol
    
    # Reset index to make date a column
    df.reset_index(inplace=True)
    df.rename(columns={'index': 'date'}, inplace=True)
    
    return df

def generate_news_data(symbols, days=90):
    """Generate synthetic cryptocurrency news data."""
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    # Template news headlines
    positive_templates = [
        "{symbol} surges as {entity} announces major investment",
        "{entity} partners with {symbol} to develop new blockchain solution",
        "{symbol} reaches new all-time high amid increased adoption",
        "Analysts bullish on {symbol} following positive regulatory news",
        "{entity} to integrate {symbol} for payment processing"
    ]
    
    negative_templates = [
        "{symbol} drops after {entity} announces regulatory investigation",
        "Security concerns arise for {symbol} blockchain",
        "{entity} sells large {symbol} holdings, causing price decline",
        "Analysts downgrade {symbol} citing market uncertainty",
        "{symbol} faces criticism from {entity} over scalability issues"
    ]
    
    neutral_templates = [
        "{entity} reviews {symbol} in latest blockchain analysis",
        "{symbol} trading volume stable as market consolidates",
        "New {symbol} update released with minor improvements",
        "{entity} discusses potential of {symbol} in recent interview",
        "{symbol} community votes on governance proposals"
    ]
    
    # Entities that might appear in news
    entities = [
        "Goldman Sachs", "JPMorgan", "BlackRock", "Vanguard", "Fidelity",
        "Morgan Stanley", "SEC", "Federal Reserve", "European Union", "Bank of Japan",
        "Citadel", "Bridgewater Associates", "Renaissance Technologies", "Celsius",
        "Two Sigma", "Binance", "Coinbase", "Kraken", "FTX", "MicroStrategy",
        "Apple", "Google", "Amazon", "Microsoft", "Meta", "Tesla"
    ]
    
    news_data = []
    
    # Generate news for each symbol
    for symbol in symbols:
        # Randomly select number of news items for this symbol (5-15)
        num_news = random.randint(5, 15)
        
        for _ in range(num_news):
            # Random date within range
            days_ago = random.randint(0, days)
            news_date = end_date - timedelta(days=days_ago)
            
            # Random sentiment with weighted probability
            sentiment = random.choices(
                ["positive", "negative", "neutral"],
                weights=[0.4, 0.3, 0.3]
            )[0]
            
            # Select template based on sentiment
            if sentiment == "positive":
                template = random.choice(positive_templates)
                impact = random.uniform(0.5, 5.0)
            elif sentiment == "negative":
                template = random.choice(negative_templates)
                impact = random.uniform(-5.0, -0.5)
            else:
                template = random.choice(neutral_templates)
                impact = random.uniform(-0.5, 0.5)
            
            # Format headline
            entity = random.choice(entities)
            headline = template.format(symbol=symbol, entity=entity)
            
            # Create news entry
            news_entry = {
                "date": news_date.strftime("%Y-%m-%d"),
                "symbol": symbol,
                "headline": headline,
                "sentiment": sentiment,
                "impact": impact,
                "source": random.choice(["Bloomberg", "Reuters", "CNBC", "Wall Street Journal", "Financial Times"])
            }
            
            news_data.append(news_entry)
    
    # Convert to DataFrame and sort by date
    news_df = pd.DataFrame(news_data)
    news_df['date'] = pd.to_datetime(news_df['date'])
    news_df.sort_values('date', inplace=True)
    
    return news_df

def generate_on_chain_data(symbols, days=90):
    """Generate synthetic on-chain data for cryptocurrencies."""
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    on_chain_data = []
    
    for symbol in symbols:
        # Base metrics that scale with each symbol
        if symbol == "BTC/USDT":
            base_symbol = "BTC"
            base_txn_count = 300000
            base_active_addresses = 1000000
            base_avg_fee = 5.0
        elif symbol == "ETH/USDT":
            base_symbol = "ETH"
            base_txn_count = 1000000
            base_active_addresses = 500000
            base_avg_fee = 10.0
        else:
            base_symbol = symbol.split('/')[0]
            base_txn_count = random.randint(50000, 200000)
            base_active_addresses = random.randint(100000, 300000)
            base_avg_fee = random.uniform(0.1, 2.0)
        
        for date in dates:
            # Add cyclical pattern (weekly)
            day_factor = 1.0 + (0.2 if date.weekday() >= 5 else 0)
            
            # Add random noise
            noise = random.uniform(0.8, 1.2)
            
            # Calculate metrics for this day
            txn_count = int(base_txn_count * day_factor * noise)
            active_addresses = int(base_active_addresses * day_factor * noise)
            avg_fee = base_avg_fee * noise
            
            # Add some trends (growing over time)
            time_factor = 1.0 + (0.001 * (dates.get_loc(date)))
            txn_count = int(txn_count * time_factor)
            active_addresses = int(active_addresses * time_factor)
            
            # Create record
            record = {
                "date": date.strftime("%Y-%m-%d"),
                "symbol": base_symbol,
                "transaction_count": txn_count,
                "active_addresses": active_addresses,
                "average_fee": avg_fee,
                "total_fees": txn_count * avg_fee,
                "average_transaction_value": random.uniform(100, 10000) * noise,
                "new_addresses": int(active_addresses * random.uniform(0.01, 0.05))
            }
            
            on_chain_data.append(record)
    
    # Convert to DataFrame and sort by date
    on_chain_df = pd.DataFrame(on_chain_data)
    on_chain_df['date'] = pd.to_datetime(on_chain_df['date'])
    on_chain_df.sort_values(['symbol', 'date'], inplace=True)
    
    return on_chain_df

def generate_social_sentiment_data(symbols, days=90):
    """Generate synthetic social media sentiment data for cryptocurrencies."""
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    sentiment_data = []
    
    for symbol in symbols:
        base_symbol = symbol.split('/')[0]
        
        for date in dates:
            # Base sentiment (slightly positive on average)
            base_sentiment = random.uniform(-0.2, 0.3)
            
            # Add noise
            noise = random.uniform(-0.2, 0.2)
            
            # Create record
            record = {
                "date": date.strftime("%Y-%m-%d"),
                "symbol": base_symbol,
                "twitter_sentiment": max(-1, min(1, base_sentiment + noise)),
                "reddit_sentiment": max(-1, min(1, base_sentiment + random.uniform(-0.3, 0.3))),
                "twitter_mentions": int(random.uniform(1000, 10000) * (1 + base_sentiment)),
                "reddit_mentions": int(random.uniform(500, 5000) * (1 + base_sentiment)),
                "social_dominance": random.uniform(0.01, 0.2)
            }
            
            sentiment_data.append(record)
    
    # Convert to DataFrame and sort by date
    sentiment_df = pd.DataFrame(sentiment_data)
    sentiment_df['date'] = pd.to_datetime(sentiment_df['date'])
    sentiment_df.sort_values(['symbol', 'date'], inplace=True)
    
    return sentiment_df

def save_data():
    """Generate and save all sample datasets."""
    
    print("Generating sample cryptocurrency data...")
    
    # Common symbols to use across datasets
    symbols = ["BTC/USDT", "ETH/USDT", "SOL/USDT", "BNB/USDT", "XRP/USDT"]
    
    # Create data directories
    raw_dir = "/workspace/mcp/rag/data/crypto/raw"
    processed_dir = "/workspace/mcp/rag/data/crypto/processed"
    
    # Generate and save OHLCV data
    print("Generating OHLCV data...")
    for symbol in symbols:
        df = generate_ohlcv_data(symbol)
        file_symbol = symbol.replace('/', '_')
        file_path = f"{raw_dir}/{file_symbol}_ohlcv.csv"
        df.to_csv(file_path, index=False)
        print(f"Saved {file_path}")
    
    # Create combined OHLCV file
    print("Creating combined OHLCV dataset...")
    combined_ohlcv = pd.concat([pd.read_csv(f"{raw_dir}/{symbol.replace('/', '_')}_ohlcv.csv") for symbol in symbols])
    combined_ohlcv.to_csv(f"{processed_dir}/combined_ohlcv.csv", index=False)
    
    # Generate and save news data
    print("Generating news data...")
    news_df = generate_news_data(symbols)
    news_df.to_csv(f"{raw_dir}/crypto_news.csv", index=False)
    
    # Generate and save on-chain data
    print("Generating on-chain data...")
    on_chain_df = generate_on_chain_data(symbols)
    on_chain_df.to_csv(f"{raw_dir}/on_chain_metrics.csv", index=False)
    
    # Generate and save social sentiment data
    print("Generating social sentiment data...")
    sentiment_df = generate_social_sentiment_data(symbols)
    sentiment_df.to_csv(f"{raw_dir}/social_sentiment.csv", index=False)
    
    # Create a metadata file with descriptions
    metadata = {
        "datasets": {
            "ohlcv": {
                "description": "Open, High, Low, Close, Volume data for major cryptocurrencies",
                "symbols": symbols,
                "timeframe": "daily",
                "columns": ["date", "symbol", "open", "high", "low", "close", "volume"]
            },
            "news": {
                "description": "News headlines and sentiment related to cryptocurrencies",
                "symbols": [s.split('/')[0] for s in symbols],
                "timeframe": "daily",
                "columns": ["date", "symbol", "headline", "sentiment", "impact", "source"]
            },
            "on_chain": {
                "description": "Blockchain metrics for major cryptocurrencies",
                "symbols": [s.split('/')[0] for s in symbols],
                "timeframe": "daily",
                "columns": ["date", "symbol", "transaction_count", "active_addresses", 
                          "average_fee", "total_fees", "average_transaction_value", "new_addresses"]
            },
            "social_sentiment": {
                "description": "Social media sentiment and mention metrics for cryptocurrencies",
                "symbols": [s.split('/')[0] for s in symbols],
                "timeframe": "daily",
                "columns": ["date", "symbol", "twitter_sentiment", "reddit_sentiment", 
                          "twitter_mentions", "reddit_mentions", "social_dominance"]
            }
        },
        "generation_date": datetime.now().strftime("%Y-%m-%d"),
        "note": "This is synthetic data for demonstration purposes only. Do not use for actual trading decisions."
    }
    
    with open(f"{raw_dir}/metadata.json", 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print("All sample data generated successfully.")
    print(f"Raw data saved to: {raw_dir}")
    print(f"Processed data saved to: {processed_dir}")

if __name__ == "__main__":
    save_data()
EOF

# Execute the Python script to generate sample data
echo -e "${YELLOW}Running Python script to generate sample data...${NC}"
python /workspace/mcp/rag/data/generate_sample_data.py

# Check if data was generated
if [ -f "/workspace/mcp/rag/data/crypto/raw/BTC_USDT_ohlcv.csv" ] && \
   [ -f "/workspace/mcp/rag/data/crypto/raw/crypto_news.csv" ] && \
   [ -f "/workspace/mcp/rag/data/crypto/raw/on_chain_metrics.csv" ] && \
   [ -f "/workspace/mcp/rag/data/crypto/raw/social_sentiment.csv" ]; then
  echo -e "${GREEN}Sample data generated successfully!${NC}"
else
  echo -e "${RED}Error: Failed to generate sample data.${NC}"
  exit 1
fi

echo -e "${GREEN}Sample cryptocurrency data is now ready for use with RAG and Agent examples.${NC}"
exit 0