require 'httparty'

# Uses the coingecko API to fetch prices for assets
class CoingeckoAPI
  include HTTParty
  base_uri 'api.coingecko.com/api/v3'

  COINS = %w[flow ethereum solana bitcoin chainlink].freeze
  CURRENCY = 'eur'.freeze

  # Use this to obtain all the coins' id in order to make API calls
  def coins
    self.class.get('/coins/list')
  rescue HTTParty::Error => e
    puts "Error fetching coins list: #{e.message}"
    []
  end

  # Use this to get the current price of any coins
  def prices(coins = COINS, currency = CURRENCY)
    ids = coins.join(',')
    self.class.get("/simple/price?ids=#{ids}&vs_currencies=#{currency}")
  rescue HTTParty::Error => e
    puts "Error fetching prices: #{e.message}"
    {}
  end
end
