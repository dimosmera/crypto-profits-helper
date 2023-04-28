require 'json'

require_relative 'coingecko'

def hello(event:, context:)
  puts 'Calling Coingecko'

  coingecko_api = CoingeckoAPI.new
  puts coingecko_api.prices

  puts "ENV['API_KEY'] = #{ENV['API_KEY']}"

  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end
