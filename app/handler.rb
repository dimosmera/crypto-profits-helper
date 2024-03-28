require 'json'
require 'yaml'

require_relative 'coingecko'
require_relative 'slack'

# Determines if we should sell or not based on the current price and profit margin given
def evaluate_buys(buys, current_price, profit_margin, slack_api)
  total_amount = 0
  asset = ''

  buys.each do |buying_data|
    buying_price = buying_data['price']
    profit_margin_to_use = buying_data['custom_profit_margin'] || profit_margin

    selling_price = buying_price * (1 + profit_margin_to_use)

    next if current_price < selling_price || buying_data['realized'] == true

    asset = buying_data['asset']
    amount = buying_data['amount']

    total_amount += amount

    profit_to_realize = ((current_price - buying_price) / buying_price) * 100
    slack_api.post_to_slack("#{amount} of #{asset} can now be sold for #{profit_to_realize}% profit")
  end

  return if total_amount.zero?

  slack_api.post_to_slack("TOTAL for #{asset}: #{total_amount} can now be sold")
end

# Calculates the profit between 2 transactions (Buy & Sell)
def calculate_profit(amount, price_bought_at, price_sold_at)
  spent = amount * price_bought_at
  earned = amount * price_sold_at
  earned - spent
end

# Calculates profits for all transactions for a specific day
def evaluate_profits(txs, date, asset, currency, slack_api)
  profits = 0
  txs.each do |tx|
    sold_date = tx['realizedDate']

    # go to next if the date is not defined
    next if defined?(sold_date).nil?

    # go to next if the date is not the one we want to evaluate
    next if sold_date != date

    # go to next if one of the prices is not not defined
    next if defined?(tx['price']).nil? || defined?(tx['realizedPrice']).nil?

    profits += calculate_profit(tx['amount'], tx['price'], tx['realizedPrice'])
  end

  slack_api.post_to_slack("On #{date} you made #{profits} #{currency} from #{asset}!")
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
  matic_buys = YAML.load_file('data/matic.yml')
  avax_buys = YAML.load_file('data/avax.yml')
  near_buys = YAML.load_file('data/near.yml')
  algo_buys = YAML.load_file('data/algo.yml')
  doge_buys = YAML.load_file('data/doge.yml')
  jup_buys = YAML.load_file('data/jup.yml')
  bonk_buys = YAML.load_file('data/bonk.yml')
  wen_buys = YAML.load_file('data/wen.yml')

  evaluate_buys(flow_buys, current_asset_prices['flow']['eur'], 0.1, slack_api)
  evaluate_buys(link_buys, current_asset_prices['chainlink']['eur'], 0.1, slack_api)
  evaluate_buys(avax_buys, current_asset_prices['avalanche-2']['eur'], 0.1, slack_api)
  evaluate_buys(near_buys, current_asset_prices['near']['eur'], 0.1, slack_api)
  evaluate_buys(algo_buys, current_asset_prices['algorand']['eur'], 0.1, slack_api)

  evaluate_buys(jup_buys, current_asset_prices['jupiter-exchange-solana']['eur'], 0.35, slack_api)
  evaluate_buys(bonk_buys, current_asset_prices['bonk']['eur'], 0.35, slack_api)
  evaluate_buys(wen_buys, current_asset_prices['wen-4']['eur'], 0.35, slack_api)

  evaluate_buys(matic_buys, current_asset_prices['matic-network']['eur'], 0.15, slack_api)

  evaluate_buys(sol_buys, current_asset_prices['solana']['eur'], 0.4, slack_api)
  evaluate_buys(doge_buys, current_asset_prices['dogecoin']['eur'], 0.35, slack_api)

  evaluate_buys(btc_buys, current_asset_prices['bitcoin']['eur'], 0.5, slack_api)
  evaluate_buys(eth_buys, current_asset_prices['ethereum']['eur'], 0.6, slack_api)

  # evaluate_profits(doge_buys, '28/03/24', 'DOGE', 'EUR', slack_api)

  {
    statusCode: 200
  }
end
