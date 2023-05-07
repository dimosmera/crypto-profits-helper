require 'json'
require 'yaml'

require_relative 'coingecko'

# determines if we should sell or not based on the current price and profit margin given
def evaluate_buys(buys, current_price, profit_margin)
  buys.each do |buying_data|
    buying_price = buying_data['price']

    selling_price = buying_price * (1 + profit_margin)
    puts selling_price

    if current_price >= selling_price
      puts 'SELL'
    else
      puts 'HOLD'
    end
  end
end

def crypto_profits(event:, context:)
  puts 'Calling Coingecko'

  coingecko_api = CoingeckoAPI.new
  puts coingecko_api.prices

  flow_buys = YAML.load_file('data/flow.yml')
  puts flow_buys

  evaluate_buys(flow_buys, coingecko_api.prices['flow']['eur'], 0.1)

  puts "ENV['API_KEY'] = #{ENV['API_KEY']}"

  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end
