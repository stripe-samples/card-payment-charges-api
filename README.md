# Collecting a card payment with the Charges API

The Charges API lets you make a simple card payment in two easy steps.

If you do business in a country with customers who use cards that may require authentication (e.g. Europe, who recently enacted [Strong Customer Authentication](https://stripe.com/docs/strong-customer-authentication/doineed)), you should use the [Payment Intents API](https://github.com/stripe-samples/web-elements-card-payment) which helps you handle banks' requests for authentication and globally scales with your business by making it easy to accept multiple payment methods.
Currently the Charges API is recommended for businesses who accept cards only in the United States and Canada.

**Demo**


Use the `4242424242424242` test card number with any CVC, postal code and future expiration date to trigger a test charge.

Use the `4000000000000002` test card number with any CVC, postal code and future expiration date to trigger a declined charge.

Read more about testing on Stripe at https://stripe.com/docs/testing.


## How to run locally
This sample includes 5 server implementations in Node, Ruby, Python, Java, and PHP. 

If you want to run the sample locally copy the .env.example file to your own .env file: 

```
cp .env.example .env
```

Then follow the instructions in the server directory to run.

You will need a Stripe account with its own set of [API keys](https://stripe.com/docs/development#api-keys).


## FAQ
Q: Why did you pick these frameworks?

A: We chose the most minimal framework to convey the key Stripe calls and concepts you need to understand. These demos are meant as an educational tool that helps you roadmap how to integrate Stripe within your own system independent of the framework.

Q: Can you show me how to build X?

A: We are always looking for new sample ideas, please email dev-samples@stripe.com with your suggestion!

## Author(s)
[@adreyfus-stripe](https://twitter.com/adrind)
