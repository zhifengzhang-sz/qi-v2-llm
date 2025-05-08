# Extended Use Cases for RAG and Agent in Quantitative Investment

This guide provides detailed examples for extending the RAG and Agent capabilities in your MCP environment for quantitative investment (QI) purposes, particularly with cryptocurrency data.

## Connecting to Additional Cryptocurrency Exchanges

The default installation includes a basic connector for major exchanges like Binance. Here's how to extend this to other exchanges:

### Available Exchanges in CCXT

The RAG and Agent components use the CCXT library, which supports 100+ cryptocurrency exchanges including:

- Binance, Binance US, Binance TR
- Coinbase Pro
- FTX
- Kraken
- KuCoin
- Huobi
- OKEx
- Bitfinex
- Bybit
- Many more...

### Adding a New Exchange Connector

To add a new exchange connector:

1. Create a new file in `/workspace/mcp/rag/src/connectors/` for your exchange:

```python
# /workspace/mcp/rag/src/connectors/kucoin_connector.py
import ccxt
import pandas as pd
from datetime import datetime, timedelta

class KuCoinConnector:
    """Connector for retrieving cryptocurrency market data from KuCoin."""
    
    def __init__(self, api_key=None, api_secret=None, password=None):
        """
        Initialize the KuCoin connector.
        
        Args:
            api_key (str, optional): API key for authenticated requests
            api_secret (str, optional): API secret for authenticated requests
            password (str, optional): API password (required for KuCoin)
        """
        self.exchange = ccxt.kucoin({
            'enableRateLimit': True,
            'apiKey': api_key,
            'secret': api_secret,
            'password': password
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
    
    def get_ticker(self, symbol):
        """Get current ticker information for a symbol."""
        return self.exchange.fetch_ticker(symbol)
    
    def get_order_book(self, symbol, limit=20):
        """Get order book for a symbol."""
        return self.exchange.fetch_order_book(symbol, limit=limit)
    
    def get_balance(self):
        """Get account balance (requires authentication)."""
        if not self.exchange.apiKey:
            raise ValueError("API key required for account balance")
        return self.exchange.fetch_balance()
```

2. Create a factory class to manage different exchange connectors:

```python
# /workspace/mcp/rag/src/connectors/exchange_factory.py
from .crypto_connector import CryptoDataConnector
from .kucoin_connector import KuCoinConnector
# Import other exchange connectors as needed

class ExchangeFactory:
    """Factory for creating exchange connectors."""
    
    @staticmethod
    def get_connector(exchange_id, api_key=None, api_secret=None, password=None):
        """
        Get connector for specified exchange.
        
        Args:
            exchange_id (str): Exchange identifier (e.g., 'binance', 'kucoin')
            api_key (str, optional): API key for authenticated requests
            api_secret (str, optional): API secret for authenticated requests
            password (str, optional): Additional authentication (for some exchanges)
            
        Returns:
            Connector instance for the specified exchange
        """
        exchange_id = exchange_id.lower()
        
        if exchange_id == 'binance':
            return CryptoDataConnector(exchange_id='binance', api_key=api_key, api_secret=api_secret)
        elif exchange_id == 'kucoin':
            return KuCoinConnector(api_key=api_key, api_secret=api_secret, password=password)
        # Add more exchange options here
        else:
            # Default to the general connector which uses ccxt under the hood
            return CryptoDataConnector(exchange_id=exchange_id, api_key=api_key, api_secret=api_secret)
```

### Securely Managing API Keys

For exchanges that require authentication:

1. Create a secure configuration file:

```bash
mkdir -p /workspace/mcp/agent/configs/keys
touch /workspace/mcp/agent/configs/keys/exchange_keys.json
chmod 600 /workspace/mcp/agent/configs/keys/exchange_keys.json
```

2. Add your API keys to this file:

```json
{
  "binance": {
    "api_key": "YOUR_BINANCE_API_KEY",
    "api_secret": "YOUR_BINANCE_API_SECRET"
  },
  "kucoin": {
    "api_key": "YOUR_KUCOIN_API_KEY",
    "api_secret": "YOUR_KUCOIN_API_SECRET",
    "password": "YOUR_KUCOIN_API_PASSWORD"
  }
}
```

3. Create a utility for securely loading these keys:

```python
# /workspace/mcp/rag/src/utils/key_manager.py
import os
import json

class KeyManager:
    """Manager for API keys."""
    
    def __init__(self, key_file=None):
        """
        Initialize the key manager.
        
        Args:
            key_file (str, optional): Path to key file
        """
        self.key_file = key_file or os.environ.get(
            'EXCHANGE_KEYS_FILE', 
            '/workspace/mcp/agent/configs/keys/exchange_keys.json'
        )
        self.keys = self._load_keys()
    
    def _load_keys(self):
        """Load keys from file."""
        if not os.path.exists(self.key_file):
            return {}
        
        try:
            with open(self.key_file, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading keys: {e}")
            return {}
    
    def get_exchange_keys(self, exchange_id):
        """
        Get keys for specified exchange.
        
        Args:
            exchange_id (str): Exchange identifier
            
        Returns:
            dict: Dictionary with keys for the exchange
        """
        return self.keys.get(exchange_id, {})
```

### Example Usage

```python
from rag.src.connectors.exchange_factory import ExchangeFactory
from rag.src.utils.key_manager import KeyManager

# For public data (no authentication)
connector = ExchangeFactory.get_connector('binance')
btc_data = connector.get_ohlcv('BTC/USDT', '1h', 100)

# For authenticated requests
key_manager = KeyManager()
keys = key_manager.get_exchange_keys('kucoin')
auth_connector = ExchangeFactory.get_connector('kucoin', **keys)
balance = auth_connector.get_balance()
```

## Building Custom Agent Tools for Trading Strategies

You can extend the agent capabilities by creating custom tools for specific trading strategies.

### Creating a Technical Analysis Tool

Here's an example of creating a tool for technical analysis:

```python
# /workspace/mcp/agent/src/tools/ta_tools.py
from langchain.tools import BaseTool
import pandas as pd
import numpy as np
import sys
import os

# Add the RAG module to path
sys.path.append("/workspace/mcp")
from rag.src.connectors.exchange_factory import ExchangeFactory

class TechnicalAnalysisTool(BaseTool):
    """Tool for performing technical analysis on cryptocurrency price data."""
    
    name = "technical_analysis"
    description = "Perform technical analysis on cryptocurrency price data"
    
    def __init__(self):
        super().__init__()
        self.exchange = ExchangeFactory.get_connector('binance')
    
    def _calculate_rsi(self, data, window=14):
        """Calculate RSI indicator."""
        delta = data.diff()
        gain = delta.where(delta > 0, 0).rolling(window=window).mean()
        loss = -delta.where(delta < 0, 0).rolling(window=window).mean()
        
        rs = gain / loss
        rsi = 100 - (100 / (1 + rs))
        return rsi
    
    def _calculate_macd(self, data, fast=12, slow=26, signal=9):
        """Calculate MACD indicator."""
        exp1 = data.ewm(span=fast, adjust=False).mean()
        exp2 = data.ewm(span=slow, adjust=False).mean()
        macd = exp1 - exp2
        signal_line = macd.ewm(span=signal, adjust=False).mean()
        histogram = macd - signal_line
        return macd, signal_line, histogram
    
    def _calculate_bollinger(self, data, window=20, num_std=2):
        """Calculate Bollinger Bands."""
        ma = data.rolling(window=window).mean()
        std = data.rolling(window=window).std()
        upper = ma + (std * num_std)
        lower = ma - (std * num_std)
        return ma, upper, lower
    
    def _run(self, query):
        """
        Run the tool on the query.
        
        Args:
            query: String in format "SYMBOL, TIMEFRAME, INDICATORS"
                   Example: "BTC/USDT, 1d, rsi,macd,bollinger"
        
        Returns:
            String representation of the technical analysis
        """
        try:
            parts = [p.strip() for p in query.split(',')]
            symbol = parts[0]
            timeframe = parts[1] if len(parts) > 1 else '1d'
            
            # Get indicators list, default to 'all' if not specified
            indicators = [i.strip().lower() for i in parts[2].split(',')] if len(parts) > 2 else ['all']
            if 'all' in indicators:
                indicators = ['rsi', 'macd', 'bollinger']
            
            # Fetch OHLCV data
            data = self.exchange.get_ohlcv(symbol, timeframe, limit=100)
            
            results = {
                'symbol': symbol,
                'timeframe': timeframe,
                'last_price': data['close'].iloc[-1],
                'price_change_24h': (data['close'].iloc[-1] / data['close'].iloc[-2] - 1) * 100,
                'indicators': {}
            }
            
            # Calculate requested indicators
            if 'rsi' in indicators:
                rsi = self._calculate_rsi(data['close'])
                results['indicators']['rsi'] = {
                    'current': rsi.iloc[-1],
                    'previous': rsi.iloc[-2],
                    'is_oversold': rsi.iloc[-1] < 30,
                    'is_overbought': rsi.iloc[-1] > 70
                }
            
            if 'macd' in indicators:
                macd, signal, histogram = self._calculate_macd(data['close'])
                results['indicators']['macd'] = {
                    'macd': macd.iloc[-1],
                    'signal': signal.iloc[-1],
                    'histogram': histogram.iloc[-1],
                    'bullish_crossover': macd.iloc[-2] < signal.iloc[-2] and macd.iloc[-1] > signal.iloc[-1],
                    'bearish_crossover': macd.iloc[-2] > signal.iloc[-2] and macd.iloc[-1] < signal.iloc[-1]
                }
            
            if 'bollinger' in indicators:
                ma, upper, lower = self._calculate_bollinger(data['close'])
                current_price = data['close'].iloc[-1]
                results['indicators']['bollinger_bands'] = {
                    'middle': ma.iloc[-1],
                    'upper': upper.iloc[-1],
                    'lower': lower.iloc[-1],
                    'bandwidth': (upper.iloc[-1] - lower.iloc[-1]) / ma.iloc[-1],
                    'is_above_upper': current_price > upper.iloc[-1],
                    'is_below_lower': current_price < lower.iloc[-1]
                }
            
            # Generate analysis text
            analysis = f"Technical Analysis for {symbol} ({timeframe}):\n"
            analysis += f"Current Price: {results['last_price']:.2f}\n"
            analysis += f"24h Change: {results['price_change_24h']:.2f}%\n\n"
            
            if 'rsi' in indicators:
                rsi_data = results['indicators']['rsi']
                analysis += f"RSI: {rsi_data['current']:.2f}\n"
                if rsi_data['is_oversold']:
                    analysis += "  - RSI indicates OVERSOLD conditions\n"
                elif rsi_data['is_overbought']:
                    analysis += "  - RSI indicates OVERBOUGHT conditions\n"
                else:
                    analysis += "  - RSI is in neutral territory\n"
            
            if 'macd' in indicators:
                macd_data = results['indicators']['macd']
                analysis += f"MACD: {macd_data['macd']:.4f}, Signal: {macd_data['signal']:.4f}\n"
                if macd_data['bullish_crossover']:
                    analysis += "  - BULLISH signal: MACD crossed above signal line\n"
                elif macd_data['bearish_crossover']:
                    analysis += "  - BEARISH signal: MACD crossed below signal line\n"
                elif macd_data['macd'] > macd_data['signal']:
                    analysis += "  - MACD above signal line (bullish)\n"
                else:
                    analysis += "  - MACD below signal line (bearish)\n"
            
            if 'bollinger' in indicators:
                bb_data = results['indicators']['bollinger_bands']
                analysis += "Bollinger Bands:\n"
                analysis += f"  - Middle: {bb_data['middle']:.2f}\n"
                analysis += f"  - Upper: {bb_data['upper']:.2f}\n"
                analysis += f"  - Lower: {bb_data['lower']:.2f}\n"
                
                if bb_data['is_above_upper']:
                    analysis += "  - Price is ABOVE upper band (potential reversal or strong uptrend)\n"
                elif bb_data['is_below_lower']:
                    analysis += "  - Price is BELOW lower band (potential reversal or strong downtrend)\n"
                else:
                    analysis += "  - Price is within Bollinger Bands\n"
            
            # Add trading recommendation
            analysis += "\nSummary:\n"
            signals = []
            
            if 'rsi' in indicators:
                if results['indicators']['rsi']['is_oversold']:
                    signals.append("BUY (RSI oversold)")
                elif results['indicators']['rsi']['is_overbought']:
                    signals.append("SELL (RSI overbought)")
            
            if 'macd' in indicators:
                if results['indicators']['macd']['bullish_crossover']:
                    signals.append("BUY (MACD bullish crossover)")
                elif results['indicators']['macd']['bearish_crossover']:
                    signals.append("SELL (MACD bearish crossover)")
            
            if 'bollinger' in indicators:
                if results['indicators']['bollinger_bands']['is_below_lower']:
                    signals.append("BUY (price below lower Bollinger Band)")
                elif results['indicators']['bollinger_bands']['is_above_upper']:
                    signals.append("SELL (price above upper Bollinger Band)")
            
            if signals:
                buy_signals = [s for s in signals if s.startswith("BUY")]
                sell_signals = [s for s in signals if s.startswith("SELL")]
                
                if len(buy_signals) > len(sell_signals):
                    analysis += "Overall recommendation: BUY"
                elif len(sell_signals) > len(buy_signals):
                    analysis += "Overall recommendation: SELL"
                else:
                    analysis += "Overall recommendation: HOLD"
                
                analysis += "\nSignals:\n"
                for signal in signals:
                    analysis += f"  - {signal}\n"
            else:
                analysis += "No clear signals. Consider HOLD."
            
            return analysis
        
        except Exception as e:
            return f"Error performing technical analysis: {str(e)}"
```

### Creating a Sentiment Analysis Tool

Here's an example of a tool that analyzes sentiment from cryptocurrency news and social media:

```python
# /workspace/mcp/agent/src/tools/sentiment_tools.py
from langchain.tools import BaseTool
import pandas as pd
import os
import sys
from datetime import datetime, timedelta

class CryptoSentimentTool(BaseTool):
    """Tool for analyzing sentiment data for cryptocurrencies."""
    
    name = "crypto_sentiment"
    description = "Analyze sentiment data from news and social media for a cryptocurrency"
    
    def __init__(self):
        super().__init__()
        self.data_dir = "/workspace/mcp/rag/data/crypto/raw"
        
        # Load data files
        self.news_file = os.path.join(self.data_dir, "crypto_news.csv")
        self.social_file = os.path.join(self.data_dir, "social_sentiment.csv")
        
        # Check if files exist
        if not os.path.exists(self.news_file) or not os.path.exists(self.social_file):
            raise FileNotFoundError("Sentiment data files not found. Run the generate-crypto-sample-data.sh script first.")
    
    def _run(self, query):
        """
        Run the tool on the query.
        
        Args:
            query: String in format "SYMBOL, DAYS"
                   Example: "BTC, 7" (for BTC sentiment over last 7 days)
        
        Returns:
            String representation of the sentiment analysis
        """
        try:
            parts = [p.strip() for p in query.split(',')]
            symbol = parts[0].upper()
            days = int(parts[1]) if len(parts) > 1 else 7
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            # Load news data
            news_df = pd.read_csv(self.news_file)
            news_df['date'] = pd.to_datetime(news_df['date'])
            
            # Filter for symbol and date range
            news_df = news_df[
                (news_df['symbol'] == symbol) & 
                (news_df['date'] >= start_date) & 
                (news_df['date'] <= end_date)
            ]
            
            # Load social sentiment data
            social_df = pd.read_csv(self.social_file)
            social_df['date'] = pd.to_datetime(social_df['date'])
            
            # Filter for symbol and date range
            social_df = social_df[
                (social_df['symbol'] == symbol) & 
                (social_df['date'] >= start_date) & 
                (social_df['date'] <= end_date)
            ]
            
            # Analyze news sentiment
            if len(news_df) > 0:
                positive_news = news_df[news_df['sentiment'] == 'positive']
                negative_news = news_df[news_df['sentiment'] == 'negative']
                neutral_news = news_df[news_df['sentiment'] == 'neutral']
                
                avg_impact = news_df['impact'].mean()
                news_summary = {
                    'total_news': len(news_df),
                    'positive_news': len(positive_news),
                    'negative_news': len(negative_news),
                    'neutral_news': len(neutral_news),
                    'avg_impact': avg_impact,
                    'recent_headlines': news_df.sort_values('date', ascending=False).head(5)['headline'].tolist()
                }
            else:
                news_summary = {
                    'total_news': 0,
                    'positive_news': 0,
                    'negative_news': 0,
                    'neutral_news': 0,
                    'avg_impact': 0,
                    'recent_headlines': []
                }
            
            # Analyze social sentiment
            if len(social_df) > 0:
                avg_twitter_sent = social_df['twitter_sentiment'].mean()
                avg_reddit_sent = social_df['reddit_sentiment'].mean()
                total_twitter_mentions = social_df['twitter_mentions'].sum()
                total_reddit_mentions = social_df['reddit_mentions'].sum()
                avg_social_dominance = social_df['social_dominance'].mean()
                
                social_summary = {
                    'avg_twitter_sentiment': avg_twitter_sent,
                    'avg_reddit_sentiment': avg_reddit_sent,
                    'total_twitter_mentions': total_twitter_mentions,
                    'total_reddit_mentions': total_reddit_mentions,
                    'avg_social_dominance': avg_social_dominance
                }
            else:
                social_summary = {
                    'avg_twitter_sentiment': 0,
                    'avg_reddit_sentiment': 0,
                    'total_twitter_mentions': 0,
                    'total_reddit_mentions': 0,
                    'avg_social_dominance': 0
                }
            
            # Generate analysis text
            analysis = f"Sentiment Analysis for {symbol} (Last {days} days):\n\n"
            
            # News sentiment analysis
            analysis += "News Sentiment:\n"
            if news_summary['total_news'] > 0:
                analysis += f"  - Total news articles: {news_summary['total_news']}\n"
                analysis += f"  - Positive news: {news_summary['positive_news']} ({news_summary['positive_news']/news_summary['total_news']*100:.1f}%)\n"
                analysis += f"  - Negative news: {news_summary['negative_news']} ({news_summary['negative_news']/news_summary['total_news']*100:.1f}%)\n"
                analysis += f"  - Neutral news: {news_summary['neutral_news']} ({news_summary['neutral_news']/news_summary['total_news']*100:.1f}%)\n"
                analysis += f"  - Average impact score: {news_summary['avg_impact']:.2f} (positive values are bullish)\n"
                
                if news_summary['recent_headlines']:
                    analysis += "\nRecent Headlines:\n"
                    for headline in news_summary['recent_headlines']:
                        analysis += f"  - {headline}\n"
            else:
                analysis += "  No news articles found for this period.\n"
            
            # Social sentiment analysis
            analysis += "\nSocial Media Sentiment:\n"
            if social_summary['total_twitter_mentions'] > 0 or social_summary['total_reddit_mentions'] > 0:
                analysis += f"  - Twitter sentiment: {social_summary['avg_twitter_sentiment']:.2f} (-1 to 1 scale)\n"
                analysis += f"  - Reddit sentiment: {social_summary['avg_reddit_sentiment']:.2f} (-1 to 1 scale)\n"
                analysis += f"  - Twitter mentions: {social_summary['total_twitter_mentions']}\n"
                analysis += f"  - Reddit mentions: {social_summary['total_reddit_mentions']}\n"
                analysis += f"  - Social dominance: {social_summary['avg_social_dominance']:.2f} (% of total crypto mentions)\n"
            else:
                analysis += "  No social media data found for this period.\n"
            
            # Overall sentiment summary
            analysis += "\nOverall Sentiment:\n"
            
            # Calculate overall sentiment score (weighted average of news and social)
            if news_summary['total_news'] > 0 or social_summary['total_twitter_mentions'] > 0:
                # Calculate news sentiment score (-1 to 1 scale)
                if news_summary['total_news'] > 0:
                    news_score = (news_summary['positive_news'] - news_summary['negative_news']) / news_summary['total_news']
                else:
                    news_score = 0
                
                # Calculate social sentiment score (average of Twitter and Reddit)
                if social_summary['total_twitter_mentions'] > 0 or social_summary['total_reddit_mentions'] > 0:
                    social_score = (social_summary['avg_twitter_sentiment'] + social_summary['avg_reddit_sentiment']) / 2
                else:
                    social_score = 0
                
                # Weight news and social equally for overall score
                overall_score = (news_score + social_score) / 2
                
                analysis += f"  - Overall sentiment score: {overall_score:.2f} (-1 to 1 scale)\n"
                
                if overall_score > 0.3:
                    analysis += "  - Market sentiment is VERY POSITIVE\n"
                elif overall_score > 0.1:
                    analysis += "  - Market sentiment is POSITIVE\n"
                elif overall_score > -0.1:
                    analysis += "  - Market sentiment is NEUTRAL\n"
                elif overall_score > -0.3:
                    analysis += "  - Market sentiment is NEGATIVE\n"
                else:
                    analysis += "  - Market sentiment is VERY NEGATIVE\n"
                
                # Trading recommendation based on sentiment
                analysis += "\nSentiment-Based Recommendation:\n"
                if overall_score > 0.2:
                    analysis += "  BUY: Positive sentiment suggests potential price increase\n"
                elif overall_score < -0.2:
                    analysis += "  SELL: Negative sentiment suggests potential price decrease\n"
                else:
                    analysis += "  HOLD: Sentiment is relatively neutral\n"
            else:
                analysis += "  Insufficient data to determine overall sentiment.\n"
            
            return analysis
        
        except Exception as e:
            return f"Error analyzing sentiment data: {str(e)}"
```

### Integrating Multiple Tools in a Comprehensive Agent

To create a more sophisticated agent that uses multiple tools for comprehensive cryptocurrency analysis:

```python
# /workspace/mcp/agent/examples/crypto_trading_agent.py
import sys
sys.path.append("/workspace/mcp")

from agent.src.models.base_agent import MCPAgent
from agent.src.tools.crypto_tools import CryptoOHLCVTool
from agent.src.tools.ta_tools import TechnicalAnalysisTool
from agent.src.tools.sentiment_tools import CryptoSentimentTool
from langchain.memory import ConversationBufferMemory

# Mock LLM for demonstration
# In a real implementation, you would use DeepSeek or another model
from langchain_core.language_models import LLM

class MockLLM(LLM):
    def _call(self, prompt, **kwargs):
        return f"This is a simulated response that would analyze the prompt:\n{prompt[:100]}..."
    
    @property
    def _llm_type(self):
        return "mock"

def create_crypto_trading_agent():
    """Create an agent specialized for cryptocurrency trading."""
    
    # Create tools
    tools = [
        CryptoOHLCVTool(),           # For raw price data
        TechnicalAnalysisTool(),      # For technical indicators
        CryptoSentimentTool()         # For sentiment analysis
    ]
    
    # Create memory
    memory = ConversationBufferMemory(
        memory_key="chat_history",
        return_messages=True
    )
    
    # Create LLM (use your preferred model here)
    llm = MockLLM()  # Replace with actual LLM
    
    # Create agent
    agent = MCPAgent(
        llm=llm,
        tools=tools,
        memory=memory
    )
    
    return agent

if __name__ == "__main__":
    # Create agent
    agent = create_crypto_trading_agent()
    
    # Example query
    query = """
    Analyze BTC/USDT with the following approach:
    1. Check the recent price and volume data
    2. Run technical analysis with RSI, MACD, and Bollinger Bands
    3. Look at sentiment from news and social media
    4. Provide a comprehensive trading recommendation
    """
    
    # Run agent
    print("Query:", query)
    print("\nAgent response would include:")
    print("1. Price data analysis")
    print("2. Technical indicator analysis")
    print("3. Sentiment analysis")
    print("4. Trading recommendation based on all factors")
    
    # In a real implementation, you would run:
    # result = agent.run(query)
    # print(result)
```

## Integrating with Existing Time Series Models

You can integrate the RAG and Agent components with your existing time series models in the MCP environment.

### Example: Creating a Hybrid Prediction Tool

```python
# /workspace/mcp/agent/src/tools/hybrid_prediction_tool.py
from langchain.tools import BaseTool
import pandas as pd
import numpy as np
import os
import sys
import joblib
from datetime import datetime, timedelta
from statsmodels.tsa.arima.model import ARIMA

# Add the RAG module to path
sys.path.append("/workspace/mcp")
from rag.src.connectors.exchange_factory import ExchangeFactory

class HybridPredictionTool(BaseTool):
    """Tool for making price predictions using traditional time series models with context awareness."""
    
    name = "hybrid_prediction"
    description = "Make cryptocurrency price predictions using hybrid models"
    
    def __init__(self):
        super().__init__()
        self.exchange = ExchangeFactory.get_connector('binance')
        self.data_dir = "/workspace/mcp/rag/data/crypto/raw"
        self.model_dir = "/workspace/mcp/agent/models"
        
        # Ensure model directory exists
        os.makedirs(self.model_dir, exist_ok=True)
    
    def _train_arima_model(self, price_data, order=(5, 1, 0)):
        """Train an ARIMA model on price data."""
        model = ARIMA(price_data, order=order)
        model_fit = model.fit()
        return model_fit
    
    def _get_sentiment_score(self, symbol, days=30):
        """Get sentiment score for a symbol."""
        try:
            # Load news data
            news_file = os.path.join(self.data_dir, "crypto_news.csv")
            if os.path.exists(news_file):
                news_df = pd.read_csv(news_file)
                news_df['date'] = pd.to_datetime(news_df['date'])
                
                # Calculate date range
                end_date = datetime.now()
                start_date = end_date - timedelta(days=days)
                
                # Filter for symbol and date range
                news_df = news_df[
                    (news_df['symbol'] == symbol.split('/')[0]) & 
                    (news_df['date'] >= start_date) & 
                    (news_df['date'] <= end_date)
                ]
                
                if len(news_df) > 0:
                    return news_df['impact'].mean()
            
            return 0  # Neutral if no data
        except:
            return 0  # Neutral on error
    
    def _run(self, query):
        """
        Run the tool on the query.
        
        Args:
            query: String in format "SYMBOL, DAYS_TO_PREDICT, MODEL_TYPE"
                   Example: "BTC/USDT, 7, arima"
        
        Returns:
            String representation of the price predictions
        """
        try:
            parts = [p.strip() for p in query.split(',')]
            symbol = parts[0]
            days_to_predict = int(parts[1]) if len(parts) > 1 else 7
            model_type = parts[2].lower() if len(parts) > 2 else 'arima'
            
            # Get historical price data
            price_data = self.exchange.get_ohlcv(symbol, '1d', limit=100)
            
            # Extract close prices
            close_prices = price_data['close']
            
            # Get sentiment score for context
            sentiment_score = self._get_sentiment_score(symbol)
            
            # Make prediction based on model type
            if model_type == 'arima':
                # Train ARIMA model
                model = self._train_arima_model(close_prices)
                
                # Make predictions
                forecast = model.forecast(steps=days_to_predict)
                
                # Adjust prediction based on sentiment
                sentiment_adjustment = 1 + (sentiment_score * 0.01)  # 1% adjustment per sentiment unit
                forecast = forecast * sentiment_adjustment
                
                # Create result
                current_price = close_prices.iloc[-1]
                result = pd.DataFrame({
                    'date': pd.date_range(start=price_data.index[-1] + pd.Timedelta(days=1), periods=days_to_predict, freq='D'),
                    'predicted_price': forecast,
                    'change_pct': ((forecast / current_price) - 1) * 100
                })
                
                # Generate analysis text
                analysis = f"Price Prediction for {symbol} (Next {days_to_predict} days):\n\n"
                analysis += f"Current Price: {current_price:.2f}\n"
                analysis += f"Sentiment Score: {sentiment_score:.2f}\n\n"
                analysis += "Daily Predictions:\n"
                
                for _, row in result.iterrows():
                    date_str = row['date'].strftime('%Y-%m-%d')
                    price = row['predicted_price']
                    change = row['change_pct']
                    direction = "▲" if change > 0 else "▼"
                    analysis += f"  {date_str}: {price:.2f} ({direction} {abs(change):.2f}%)\n"
                
                # Add summary
                final_change = result['change_pct'].iloc[-1]
                if final_change > 5:
                    analysis += "\nOverall: Strongly Bullish outlook"
                elif final_change > 0:
                    analysis += "\nOverall: Mildly Bullish outlook"
                elif final_change > -5:
                    analysis += "\nOverall: Mildly Bearish outlook"
                else:
                    analysis += "\nOverall: Strongly Bearish outlook"
                
                # Add hybrid model explanation
                analysis += "\n\nModel Details:"
                analysis += "\n- Base Model: ARIMA time series forecasting"
                analysis += f"\n- Sentiment Adjustment: {sentiment_adjustment:.2f}x multiplier based on news sentiment"
                analysis += "\n- This is a hybrid model combining traditional time series analysis with context from news sentiment"
                
                return analysis
            else:
                return f"Model type '{model_type}' is not supported. Try 'arima'."
        
        except Exception as e:
            return f"Error making predictions: {str(e)}"
```

The above examples demonstrate how to extend the RAG and Agent components for more advanced quantitative investment workflows.

For a complete implementation, you would add these files to your RAG and Agent directories and then update the example notebooks to showcase their use.

## Conclusion

By extending the RAG and Agent components as shown in these examples, you can create powerful tools for cryptocurrency analysis and quantitative investment. The integration with the existing MCP environment allows you to leverage both traditional time series models and context-aware AI systems for more comprehensive market analysis.