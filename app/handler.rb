require 'json'
require 'yaml'

require_relative 'coingecko'
require_relative 'slack'

# Determines if we should sell or not based on the current price and profit margin given
def evaluate_buys(buys, current_price, profit_margin, slack_api)
  buys.each do |buying_data|
    buying_price = buying_data['price']

    selling_price = buying_price * (1 + profit_margin)

    next if current_price < selling_price || buying_data['realized'] == true

    asset = buying_data['asset']
    amount = buying_data['amount']

    profit_to_realize = ((current_price - buying_price) / buying_price) * 100
    slack_api.post_to_slack("#{amount} of #{asset} can now be sold for #{profit_to_realize}% profit")
  end
end

# Called every <interval> hours. Check serverless.yml
def crypto_profits(event:, context:)
  coingecko_api = CoingeckoAPI.new
  current_asset_prices = coingecko_api.prices
  puts current_asset_prices

  slack_api = SlackAPI.new

  flow_buys = YAML.load_file('data/flow.yml')
  sol_buys = YAML.load_file('data/sol.yml')
  btc_buys = YAML.load_file('data/btc.yml')
  eth_buys = YAML.load_file('data/eth.yml')
  link_buys = YAML.load_file('data/link.yml')

  evaluate_buys(flow_buys, current_asset_prices['flow']['eur'], 0.1, slack_api)
  evaluate_buys(sol_buys, current_asset_prices['solana']['eur'], 0.2, slack_api)
  evaluate_buys(btc_buys, current_asset_prices['bitcoin']['eur'], 0.3, slack_api)
  evaluate_buys(eth_buys, current_asset_prices['ethereum']['eur'], 0.3, slack_api)
  evaluate_buys(link_buys, current_asset_prices['chainlink']['eur'], 0.1, slack_api)

  {
    statusCode: 200
  }
end
