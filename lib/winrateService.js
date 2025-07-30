import { supabaseOperations } from './supabase'

export class WinRateService {
  constructor() {
    this.intervalId = null
    this.isRunning = false
    this.lastCalculation = null
  }

  // Calculate win rate for different time periods
  async calculateWinRates() {
    const now = Date.now()
    const periods = {
      '1h': now - (1 * 60 * 60 * 1000),
      '4h': now - (4 * 60 * 60 * 1000), 
      '24h': now - (24 * 60 * 60 * 1000),
      '7d': now - (7 * 24 * 60 * 60 * 1000),
      '30d': now - (30 * 24 * 60 * 60 * 1000)
    }

    const winrateData = {
      timestamp: now,
      winrate_1h: 0,
      winrate_4h: 0,
      winrate_24h: 0,
      winrate_7d: 0,
      winrate_30d: 0,
      trades_1h: 0,
      trades_4h: 0,
      trades_24h: 0,
      trades_7d: 0,
      trades_30d: 0,
      wins_1h: 0,
      wins_4h: 0,
      wins_24h: 0,
      wins_7d: 0,
      wins_30d: 0
    }

    try {
      // Calculate for each period
      for (const [period, startTime] of Object.entries(periods)) {
        const trades = await supabaseOperations.getTradesInTimeRange(startTime, now)
        
        if (trades && trades.length > 0) {
          const wins = trades.filter(trade => trade.pnl > 0).length
          const totalTrades = trades.length
          const winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : 0

          winrateData[`winrate_${period}`] = Math.round(winRate * 100) / 100 // Round to 2 decimals
          winrateData[`trades_${period}`] = totalTrades
          winrateData[`wins_${period}`] = wins
        }
      }

      // Save to database
      await supabaseOperations.saveWinrateSnapshot(winrateData)
      
      this.lastCalculation = winrateData
      console.log('✅ WinRate calculated and saved:', winrateData)
      
      return winrateData
    } catch (error) {
      console.error('❌ Error calculating win rates:', error)
      throw error
    }
  }

  // Start automatic calculation every 5 minutes
  start() {
    if (this.isRunning) {
      console.log('WinRate service already running')
      return
    }

    this.isRunning = true
    console.log('🚀 Starting WinRate calculation service (every 5 minutes)')
    
    // Calculate immediately
    this.calculateWinRates().catch(console.error)
    
    // Set interval for every 5 minutes (300,000 ms)
    this.intervalId = setInterval(() => {
      this.calculateWinRates().catch(console.error)
    }, 5 * 60 * 1000)
  }

  // Stop the service
  async stop() {
    if (!this.isRunning) {
      console.log('WinRate service not running')
      return
    }

    this.isRunning = false
    
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }

    // Calculate one final time when stopping
    console.log('🛑 Stopping WinRate service - calculating final winrate')
    await this.calculateWinRates()
    
    console.log('✅ WinRate service stopped')
  }

  // Get current win rate data
  getCurrentWinRates() {
    return this.lastCalculation
  }

  // Manual trigger for win rate calculation
  async triggerCalculation() {
    console.log('🔄 Manual WinRate calculation triggered')
    return await this.calculateWinRates()
  }
}

// Export singleton instance
export const winRateService = new WinRateService()