#! /usr/bin/env python3.6

"""
server.py
Stripe Sample.
Python 3.6 or newer required.
"""

import stripe
import json
import os

from flask import Flask, render_template, jsonify, request, send_from_directory
from dotenv import load_dotenv, find_dotenv

# Setup Stripe python client library
load_dotenv(find_dotenv())
stripe.api_key = os.getenv('STRIPE_SECRET_KEY')
stripe.api_version = os.getenv('STRIPE_API_VERSION')

static_dir = str(os.path.abspath(os.path.join(__file__ , "..", os.getenv("STATIC_DIR"))))
app = Flask(__name__, static_folder=static_dir,
            static_url_path="", template_folder=static_dir)

@app.route('/', methods=['GET'])
def get_example():
    # Display checkout page
    return render_template('index.html')


def calculate_order_amount(items):
    # Replace this constant with a calculation of the order's amount
    # Calculate the order total on the server to prevent
    # people from directly manipulating the amount on the client
    return 1400


@app.route('/stripe-key', methods=['GET'])
def fetch_key():
    # Send publishable key to client
    return jsonify({'publicKey': os.getenv('STRIPE_PUBLISHABLE_KEY')})


@app.route('/pay', methods=['POST'])
def pay():
    data = json.loads(request.data)
    try:
        order_amount = calculate_order_amount(data['items'])

        charge = stripe.Charge.create(
            amount=order_amount,
            currency='usd',
            source=data['token'],
        )
        
        # That's it! You're done! The payment was processed 
        return jsonify(charge)
    except stripe.error.CardError as e:
        # Handle "hard declines" e.g. insufficient funds, expired card, etc
        # See https://stripe.com/docs/declines/codes for more
        return jsonify({'error': e.user_message})



if __name__ == '__main__':
    app.run()
