<?php
use Slim\Http\Request;
use Slim\Http\Response;
use Stripe\Stripe;

require 'vendor/autoload.php';

$dotenv = Dotenv\Dotenv::create(__DIR__);
$dotenv->load();

require './config.php';

if (PHP_SAPI == 'cli-server') {
  $_SERVER['SCRIPT_NAME'] = '/index.php';
}

$app = new \Slim\App;

// Instantiate the logger as a dependency
$container = $app->getContainer();
$container['logger'] = function ($c) {
  $settings = $c->get('settings')['logger'];
  $logger = new Monolog\Logger($settings['name']);
  $logger->pushProcessor(new Monolog\Processor\UidProcessor());
  $logger->pushHandler(new Monolog\Handler\StreamHandler(__DIR__ . '/logs/app.log', \Monolog\Logger::DEBUG));
  return $logger;
};

$app->add(function ($request, $response, $next) {
    Stripe::setApiKey(getenv('STRIPE_SECRET_KEY'));
    return $next($request, $response);
});


$app->get('/', function (Request $request, Response $response, array $args) {   
  // Display checkout page
  return $response->write(file_get_contents(getenv('STATIC_DIR') . '/index.html'));
});

function calculateOrderAmount($items)
{
  // Replace this constant with a calculation of the order's amount
  // You should always calculate the order total on the server to prevent
  // people from directly manipulating the amount on the client
  return 1400;
}

$app->get('/stripe-key', function (Request $request, Response $response, array $args) {
  $pubKey = getenv('STRIPE_PUBLISHABLE_KEY');
  return $response->withJson(['publicKey' => $pubKey]);
});

$app->post('/pay', function(Request $request, Response $response) use ($app)  {
  $body = json_decode($request->getBody());
  try {
    $charge = \Stripe\Charge::create([
      'amount' => calculateOrderAmount($body->items),
      'currency' => 'usd',
      'source' => $body->token
    ]);

    // That's it! You're done! The payment was processed
    return $response->withJson($charge);
  } catch (\Stripe\Error\Card $e) {
    // Handle "hard declines" e.g. insufficient funds, expired card, etc
    // See https://stripe.com/docs/declines/codes for more
    return $response->withJson(['error' => $e->getMessage()]);
  }
});

$app->run();
