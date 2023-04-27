require 'json'
require 'httparty'

def hello(event:, context:)
  puts "Calling GitHub"

  puts "ENV['API_KEY'] = #{ENV['API_KEY']}"

  body = HTTParty.get("https://github.com").body
  puts body

  {
    statusCode: 200,
    body: {
      message: 'Go Serverless v1.0! Your function executed successfully!',
      input: event
    }.to_json
  }
end
