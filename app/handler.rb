require 'json'
require 'yaml'

require_relative 'coingecko'
require_relative 'slack'

# determines if we should sell or not based on the current price and profit margin given
def evaluate_buys(buys, current_price, profit_margin, slack_api)
  buys.each do |buying_data|
    buying_price = buying_data['price']
    asset = buying_data['asset']
    amount = buying_data['amount']

    selling_price = buying_price * (1 + profit_margin)
    puts selling_price

    if current_price >= selling_price
      slack_api.post_to_slack("#{amount} of #{asset} can now be sold for #{profit_margin * 100}% profit")
    else
      puts 'HOLD'
    end
  end
end

def crypto_profits(event:, context:)
  puts 'Calling Coingecko'

  coingecko_api = CoingeckoAPI.new
  puts coingecko_api.prices

  slack_api = SlackAPI.new

  flow_buys = YAML.load_file('data/flow.yml')
  puts flow_buys

  evaluate_buys(flow_buys, coingecko_api.prices['flow']['eur'], 0.1, slack_api)

  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end
