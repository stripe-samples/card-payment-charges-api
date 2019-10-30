# frozen_string_literal: true

require 'stripe'
require 'sinatra'
require 'dotenv'

# Replace if using a different env file or config
Dotenv.load
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :static, true
set :public_folder, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])
set :port, 4242

get '/' do
  # Display checkout page
  content_type 'text/html'
  send_file File.join(settings.public_folder, 'index.html')
end

def calculate_order_amount(_items)
  # Replace this constant with a calculation of the order's amount
  # Calculate the order total on the server to prevent
  # people from directly manipulating the amount on the client
  1400
end

get '/stripe-key' do
  content_type 'application/json'
  # Send publishable key to client
  {
    publicKey: ENV['STRIPE_PUBLISHABLE_KEY']
  }.to_json
end

post '/pay' do
  content_type 'application/json'
  data = JSON.parse(request.body.read)
  order_amount = calculate_order_amount(data['items'])
  begin
    charge = Stripe::Charge.create(
      amount: order_amount,
      currency: 'usd',
      source: data['token']
    )

    # That's it! You're done! The payment was processed
    charge.to_json
  rescue Stripe::CardError => e
    # Handle "hard declines" e.g. insufficient funds, expired card, etc
    # See https://stripe.com/docs/declines/codes for more

    {
      error: e.message
    }.to_json
  end
end
