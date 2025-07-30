-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Trades table
CREATE TABLE IF NOT EXISTS trades (
    id TEXT PRIMARY KEY,
    symbol TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('BUY', 'SELL')),
    quantity DECIMAL(20, 8) NOT NULL,
    entry_price DECIMAL(20, 4),
    exit_price DECIMAL(20, 4),
    stop_loss DECIMAL(20, 4),
    take_profit DECIMAL(20, 4),
    timestamp BIGINT NOT NULL,
    close_time BIGINT,
    status TEXT NOT NULL CHECK (status IN ('OPEN', 'CLOSED', 'CANCELLED')),
    pnl DECIMAL(20, 2),
    close_reason TEXT,
    signal_score DECIMAL(5, 2),
    counter_trend BOOLEAN DEFAULT FALSE,
    is_testnet BOOLEAN DEFAULT TRUE,
    trade_id INTEGER,
    execution_delay INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance snapshots table
CREATE TABLE IF NOT EXISTS performance_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp BIGINT NOT NULL,
    total_trades INTEGER NOT NULL DEFAULT 0,
    winning_trades INTEGER NOT NULL DEFAULT 0,
    losing_trades INTEGER NOT NULL DEFAULT 0,
    winrate DECIMAL(5, 2) NOT NULL DEFAULT 0,
    total_pnl DECIMAL(20, 2) NOT NULL DEFAULT 0,
    balance_usdt DECIMAL(20, 2) NOT NULL DEFAULT 10000,
    balance_btc DECIMAL(20, 8) NOT NULL DEFAULT 0,
    max_drawdown DECIMAL(5, 2) DEFAULT 0,
    profit_factor DECIMAL(10, 4) DEFAULT 0,
    sharpe_ratio DECIMAL(10, 4) DEFAULT 0,
    avg_win DECIMAL(20, 2) DEFAULT 0,
    avg_loss DECIMAL(20, 2) DEFAULT 0,
    largest_win DECIMAL(20, 2) DEFAULT 0,
    largest_loss DECIMAL(20, 2) DEFAULT 0,
    consecutive_wins INTEGER DEFAULT 0,
    consecutive_losses INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Winrate snapshots table (calculated every 5 minutes)
CREATE TABLE IF NOT EXISTS winrate_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp BIGINT NOT NULL,
    winrate_1h DECIMAL(5, 2) NOT NULL DEFAULT 0,
    winrate_4h DECIMAL(5, 2) NOT NULL DEFAULT 0,
    winrate_24h DECIMAL(5, 2) NOT NULL DEFAULT 0,
    winrate_7d DECIMAL(5, 2) NOT NULL DEFAULT 0,
    winrate_30d DECIMAL(5, 2) NOT NULL DEFAULT 0,
    trades_1h INTEGER NOT NULL DEFAULT 0,
    trades_4h INTEGER NOT NULL DEFAULT 0,
    trades_24h INTEGER NOT NULL DEFAULT 0,
    trades_7d INTEGER NOT NULL DEFAULT 0,
    trades_30d INTEGER NOT NULL DEFAULT 0,
    wins_1h INTEGER NOT NULL DEFAULT 0,
    wins_4h INTEGER NOT NULL DEFAULT 0,
    wins_24h INTEGER NOT NULL DEFAULT 0,
    wins_7d INTEGER NOT NULL DEFAULT 0,
    wins_30d INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bot settings table
CREATE TABLE IF NOT EXISTS bot_settings (
    id TEXT PRIMARY KEY DEFAULT 'main',
    risk_per_trade DECIMAL(5, 2) NOT NULL DEFAULT 1.0,
    rrr DECIMAL(5, 2) NOT NULL DEFAULT 2.5,
    ema_short INTEGER NOT NULL DEFAULT 9,
    ema_long INTEGER NOT NULL DEFAULT 21,
    rsi_period INTEGER NOT NULL DEFAULT 14,
    stochastic_period INTEGER NOT NULL DEFAULT 14,
    macd_fast INTEGER NOT NULL DEFAULT 12,
    macd_slow INTEGER NOT NULL DEFAULT 26,
    macd_signal INTEGER NOT NULL DEFAULT 9,
    atr_period INTEGER NOT NULL DEFAULT 14,
    testnet_mode BOOLEAN NOT NULL DEFAULT TRUE,
    auto_trade BOOLEAN NOT NULL DEFAULT FALSE,
    max_open_trades INTEGER NOT NULL DEFAULT 3,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Balance snapshots table
CREATE TABLE IF NOT EXISTS balance_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp BIGINT NOT NULL,
    usdt DECIMAL(20, 2) NOT NULL DEFAULT 10000,
    btc DECIMAL(20, 8) NOT NULL DEFAULT 0,
    total_value_usdt DECIMAL(20, 2) NOT NULL DEFAULT 10000,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bot logs table
CREATE TABLE IF NOT EXISTS bot_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  timestamp BIGINT NOT NULL,
  level TEXT NOT NULL CHECK (level IN ('INFO', 'WARNING', 'ERROR', 'SUCCESS')),
  message TEXT NOT NULL,
  data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Current balance table (single row to track live balance)
CREATE TABLE IF NOT EXISTS current_balance (
  id INTEGER PRIMARY KEY DEFAULT 1,
  usdt DECIMAL(20, 8) NOT NULL DEFAULT 10000,
  btc DECIMAL(20, 8) NOT NULL DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT single_balance_row CHECK (id = 1)
);

-- Insert initial balance
INSERT INTO current_balance (id, usdt, btc) VALUES (1, 10000, 0) ON CONFLICT (id) DO NOTHING;

-- Market data cache table (for storing candlestick data)
CREATE TABLE IF NOT EXISTS market_data_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    symbol TEXT NOT NULL,
    timeframe TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    open_price DECIMAL(20, 4) NOT NULL,
    high_price DECIMAL(20, 4) NOT NULL,
    low_price DECIMAL(20, 4) NOT NULL,
    close_price DECIMAL(20, 4) NOT NULL,
    volume DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(symbol, timeframe, timestamp)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_trades_timestamp ON trades(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_trades_symbol ON trades(symbol);
CREATE INDEX IF NOT EXISTS idx_trades_status ON trades(status);
CREATE INDEX IF NOT EXISTS idx_trades_is_testnet ON trades(is_testnet);

CREATE INDEX IF NOT EXISTS idx_performance_timestamp ON performance_snapshots(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_winrate_timestamp ON winrate_snapshots(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_balance_timestamp ON balance_snapshots(timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_bot_logs_timestamp ON bot_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_bot_logs_level ON bot_logs(level);

CREATE INDEX IF NOT EXISTS idx_market_data_symbol_timeframe ON market_data_cache(symbol, timeframe);
CREATE INDEX IF NOT EXISTS idx_market_data_timestamp ON market_data_cache(timestamp DESC);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_trades_updated_at 
    BEFORE UPDATE ON trades 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bot_settings_updated_at 
    BEFORE UPDATE ON bot_settings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE trades ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE winrate_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE balance_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_data_cache ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users (you can make this more restrictive)
CREATE POLICY "Allow all operations for authenticated users" ON trades FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON performance_snapshots FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON winrate_snapshots FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON bot_settings FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON balance_snapshots FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON bot_logs FOR ALL USING (true);
CREATE POLICY "Allow all operations for authenticated users" ON market_data_cache FOR ALL USING (true);

-- Insert default bot settings
INSERT INTO bot_settings (id) VALUES ('main') ON CONFLICT (id) DO NOTHING;