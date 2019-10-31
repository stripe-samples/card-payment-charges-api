# Collecting a card payment with the Charges API

The Charges API lets you make a simple card payment in two easy steps.

If you do business in a country with customers who use cards that may require authentication (e.g. Europe, who recently enacted [Strong Customer Authentication](https://stripe.com/docs/strong-customer-authentication/doineed)), you should use the [Payment Intents API](https://github.com/stripe-samples/web-elements-card-payment) which helps you handle banks' requests for authentication and globally scales with your business by making it easy to accept multiple payment methods.
Currently the Charges API is recommended for businesses who accept cards only in the United States and Canada.

<img src="./charge-api.gif" alt="A gif of a card payment form accepting a payment" align="center">

**Demo**

Web: See the sample [live](https://1mtjh.sse.codesandbox.io/) in test mode or [fork](https://codesandbox.io/s/stripe-sample-web-card-payment-1mtjh) the Node implementation on CodeSandbox.

iOS and Android: 
1. Clone this repo and run the sample server locally (see below).  
2. Then, navigate to the `client/ios` or `client/android` directory and follow the README there.

Use the `4242424242424242` test card number with any CVC, postal code and future expiration date to trigger a test charge.

Use the `4000000000000002` test card number with any CVC, postal code and future expiration date to trigger a declined charge.

Read more about testing on Stripe at https://stripe.com/docs/testing.


## How to run the server locally
This sample includes 5 server implementations in Node, Ruby, Python, Java, and PHP. 

Follow the steps below to run locally.

**1. Clone and configure the sample**

The Stripe CLI is the fastest way to clone and configure a sample to run locally. 

**Using the Stripe CLI**

If you haven't already installed the CLI, follow the [installation steps](https://github.com/stripe/stripe-cli#installation) in the project README. The CLI is useful for cloning samples and locally testing webhooks and Stripe integrations.

In your terminal shell, run the Stripe CLI command to clone the sample:

```
stripe samples create card-payment-charges-api
```

The CLI will walk you through picking your integration type, server and client languages, and configuring your .env config file with your Stripe API keys. 

**Installing and cloning manually**

If you do not want to use the Stripe CLI, you can manually clone and configure the sample yourself:

```
git clone https://github.com/stripe-samples/card-payment-charges-api
```

Copy the .env.example file into a file named .env in the folder of the server you want to use. For example:

```
cp .env.example using-webhooks/server/node/.env
```

You will need a Stripe account in order to run the demo. Once you set up your account, go to the Stripe [developer dashboard](https://stripe.com/docs/development#api-keys) to find your API keys.

```
STRIPE_PUBLISHABLE_KEY=<replace-with-your-publishable-key>
STRIPE_SECRET_KEY=<replace-with-your-secret-key>
```

`STATIC_DIR` tells the server where to the client files are located and does not need to be modified unless you move the server files.

**2. Follow the server instructions on how to run:**

Pick the server language you want and follow the instructions in the server folder README on how to run.

For example, if you want to run the Node server in `using-webhooks`:

```
cd using-webhooks/server/node # there's a README in this folder with instructions
npm install
npm start
```
## FAQ
Q: Why did you pick these frameworks?

A: We chose the most minimal framework to convey the key Stripe calls and concepts you need to understand. These demos are meant as an educational tool that helps you roadmap how to integrate Stripe within your own system independent of the framework.

Q: Can you show me how to build X?

A: We are always looking for new sample ideas, please email dev-samples@stripe.com with your suggestion!

## Author(s)
- [@adreyfus-stripe](https://twitter.com/adrind)
- [@yuki-stripe](https://github.com/yuki-stripe)
