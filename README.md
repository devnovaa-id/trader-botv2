# Airo Hunter Trading Bot

**Secured by Airo Hunter Security**

A professional-grade cryptocurrency trading bot built with Next.js, featuring real-time market analysis, automated trading signals, and comprehensive performance tracking. This system operates in TESTNET mode with real market data simulation.

## 🛡️ Security Features

- **Secure Authentication**: Login system with JWT tokens and "Remember Me" functionality
- **Airo Hunter Security**: Protected by enterprise-grade security protocols
- **Environment-based Configuration**: Secure credential management via .env variables
- **Session Management**: Configurable session duration (1 hour default, 24 hours with Remember Me)

## 🚀 Features

### Core Trading Features
- **Real-time Market Data**: Live price feeds from Binance WebSocket
- **Multi-timeframe Analysis**: 5m, 15m, 1h, 4h, 1d chart analysis
- **Technical Indicators**: 
  - EMA (Exponential Moving Average)
  - RSI (Relative Strength Index)
  - Stochastic Oscillator
  - MACD (Moving Average Convergence Divergence)
  - ATR (Average True Range)
  - Fibonacci retracement levels

### Automated Trading
- **Smart Signal Generation**: AI-powered trading signals with scoring system
- **Risk Management**: Configurable risk per trade and Risk-Reward Ratio (RRR)
- **Position Management**: Automatic Stop Loss and Take Profit execution
- **Counter-trend Detection**: Advanced market condition analysis

### Performance Tracking
- **Real-time Win Rate Calculation**: Updated every 5 minutes
- **Performance Metrics**: 
  - Total trades, Win/Loss ratio
  - Average win/loss amounts
  - Maximum drawdown
  - Profit factor and Sharpe ratio
  - Consecutive loss tracking
- **Historical Data**: Complete trade history with detailed analytics

### Data Persistence
- **Supabase Integration**: Cloud database for trade data, performance metrics, and logs
- **Automatic Backups**: All trading data saved to secure cloud storage
- **Win Rate Snapshots**: Time-series win rate data for multiple timeframes (1h, 4h, 24h, 7d, 30d)

## 🛠️ Technology Stack

- **Frontend**: Next.js 15.4.4, React 19, TailwindCSS
- **Charts**: Chart.js, Recharts, TradingView Widgets
- **Authentication**: JWT tokens with secure cookie management
- **Database**: Supabase (PostgreSQL)
- **Real-time Data**: Binance WebSocket API
- **Technical Analysis**: Custom indicators library
- **Security**: Airo Hunter Security protocols

## 📋 Prerequisites

- Node.js 18+ 
- npm or yarn
- Supabase account and project
- Environment variables configured

## 🔧 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd airo-hunter-trading-bot
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration
Create a `.env.local` file in the root directory:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Authentication Configuration  
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

# Application Configuration
NEXT_PUBLIC_APP_NAME=Airo Hunter Trading Bot
NEXT_PUBLIC_SECURITY_BRAND=Airo Hunter Security
```

### 4. Database Setup
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL schema from `supabase/schema.sql` in your Supabase SQL editor
3. Update your environment variables with the Supabase URL and anon key

### 5. Run the Application
```bash
# Development mode
npm run dev

# Production build
npm run build
npm start
```

The application will be available at `http://localhost:3000`

## 🔐 Authentication

### Default Credentials
- **Username**: `admin` (configurable via ADMIN_USERNAME env var)
- **Password**: Set via ADMIN_PASSWORD env var

### Session Management
- **Standard Session**: 1 hour
- **Remember Me**: 24 hours
- **Security**: JWT tokens with secure HTTP-only cookies

## 📊 Database Schema

The system uses the following main tables:

### trades
Stores all trading transactions with detailed metadata:
- Trade execution details (entry/exit prices, stop loss, take profit)
- Performance metrics (PnL, signal score)
- Timing information (timestamps, execution delays)
- Status tracking (OPEN, CLOSED, CANCELLED)

### performance_snapshots
Historical performance data:
- Trading statistics (win rate, total trades, PnL)
- Risk metrics (max drawdown, consecutive losses)
- Balance information (USDT, BTC, total value)

### winrate_snapshots
Time-series win rate data:
- Multiple timeframes (1h, 4h, 24h, 7d, 30d)
- Trade counts and win counts per period
- Calculated every 5 minutes during bot operation

### bot_settings
Configurable trading parameters:
- Risk management settings
- Technical indicator periods
- Trading mode preferences

### Additional Tables
- `balance_snapshots`: Historical balance data
- `bot_logs`: System logs and events
- `market_data_cache`: Cached market data for performance

## 🎮 Usage

### 1. Login
Navigate to `/login` and enter your credentials. Use "Remember Me" for extended sessions.

### 2. Bot Operation
- **Start Bot**: Click the green "Start" button to begin automated trading
- **Stop Bot**: Click the red "Stop" button to halt trading operations
- **Refresh**: Manually refresh market data
- **Reset Testnet**: Clear all testnet data and start fresh

### 3. Monitoring
- **Real-time Charts**: Monitor price action and technical indicators
- **Active Positions**: View open trades with current P&L
- **Trade History**: Review closed trades and performance
- **Performance Stats**: Track win rate, drawdown, and other metrics

### 4. Settings Configuration
Adjust trading parameters:
- **Risk per Trade**: Percentage of balance to risk per trade
- **Risk-Reward Ratio**: Target profit vs acceptable loss
- **Technical Indicators**: Customize indicator periods and thresholds

## 📈 Win Rate Calculation

The system ensures accurate win rate calculation:

- **Real-time Updates**: Win rate recalculated every 5 minutes during bot operation
- **Final Calculation**: Performed when bot is stopped
- **Multiple Timeframes**: 1h, 4h, 24h, 7d, 30d win rates maintained
- **No N/A Values**: Always displays numerical win rate (0.00% minimum)
- **Historical Tracking**: All calculations saved to database for analysis

## 🔧 Technical Configuration

### Risk Management
- **Position Sizing**: Based on ATR and risk percentage
- **Stop Loss**: Automatic placement based on technical levels
- **Take Profit**: Multiple targets with position scaling
- **Maximum Open Trades**: Configurable limit to prevent overexposure

### Signal Generation
- **Multi-indicator Confluence**: Requires multiple confirmations
- **Scoring System**: 0-6 point scale for signal strength
- **Counter-trend Detection**: Identifies potential reversal opportunities
- **Market Condition Analysis**: Adapts to trending vs ranging markets

## 🚨 Important Notes

### TESTNET Mode
- **Demo Trading Only**: No real money involved
- **Real Market Data**: Uses live price feeds for accurate simulation
- **Risk-free Learning**: Perfect for strategy testing and learning
- **Performance Tracking**: Full analytics without financial risk

### Security Considerations
- **Secure Authentication**: Never share login credentials
- **Environment Variables**: Keep .env.local file secure and private
- **Database Access**: Ensure Supabase project security settings are properly configured
- **Session Management**: Log out when finished, especially on shared devices

## 🐛 Troubleshooting

### Common Issues

1. **Login Problems**
   - Verify ADMIN_USERNAME and ADMIN_PASSWORD in .env.local
   - Check JWT_SECRET is set
   - Clear browser cookies and try again

2. **Database Connection Issues**
   - Verify Supabase URL and anon key
   - Check Supabase project is active
   - Ensure database schema is properly installed

3. **WebSocket Connection Issues**
   - Check internet connection
   - Verify Binance API accessibility
   - Try refreshing the page

4. **Win Rate Shows 0.00%**
   - This is normal when no trades have been executed
   - Win rate will update after first completed trade
   - Check bot logs for trading activity

### Getting Help
1. Check browser console for error messages
2. Review bot logs in the application
3. Verify all environment variables are set correctly
4. Ensure Supabase database schema is complete

## 🔄 Updates & Maintenance

### Regular Maintenance
- Monitor Supabase usage and storage
- Review and rotate JWT secrets periodically
- Update dependencies regularly for security patches
- Backup database data before major updates

### Performance Optimization
- Monitor database query performance
- Clean up old log entries periodically
- Optimize WebSocket connection handling
- Review and update technical indicator parameters

## 📄 License

This project is secured by Airo Hunter Security. All rights reserved.

## 🤝 Support

For technical support or security concerns, contact the Airo Hunter Security team.

---

**⚠️ Disclaimer**: This is a demo trading bot for educational purposes. Always test thoroughly before any real trading implementation. Past performance does not guarantee future results.
