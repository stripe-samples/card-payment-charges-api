<?php

require_once 'shared.php';

function calculateOrderAmount($items) {
	// Replace this constant with a calculation of the order's amount
	// Calculate the order total on the server to prevent
	// people from directly manipulating the amount on the client
	return 1400;
}

try {
  	$charge = \Stripe\Charge::create([
		"amount" => calculateOrderAmount($body->items),
		"currency" => "usd",
		"source" => $body->token
  ]);

  // That's it! You're done! The payment was processed 
  echo json_encode($charge);
} catch (\Stripe\Error\Card $e) {
  // Handle "hard declines" e.g. insufficient funds, expired card, etc
  // See https://stripe.com/docs/declines/codes for more
  echo json_encode(["error"=> $e->getMessage()]);
}
