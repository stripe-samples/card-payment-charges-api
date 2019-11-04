// A reference to Stripe.js
var stripe;

var orderData = {
  items: [{ id: "photo-subscription" }],
  currency: "usd"
};

// Disable the button until we have Stripe set up on the page
document.querySelector("button").disabled = true;

fetch("/stripe-key")
  .then(function(result) {
    return result.json();
  })
  .then(function(data) {
    return setupElements(data);
  })
  .then(function({ stripe, card, clientSecret }) {
    document.querySelector("button").disabled = false;

    var form = document.getElementById("payment-form");
    form.addEventListener("submit", function(event) {
      event.preventDefault();
      pay(stripe, card, clientSecret);
    });
  });

var setupElements = function(data) {
  stripe = Stripe(data.publicKey);
  /* ------- Set up Stripe Elements to use in checkout form ------- */
  var elements = stripe.elements();
  var style = {
    base: {
      color: "#32325d",
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: "antialiased",
      fontSize: "16px",
      "::placeholder": {
        color: "#aab7c4"
      }
    },
    invalid: {
      color: "#fa755a",
      iconColor: "#fa755a"
    }
  };

  var card = elements.create("card", { style: style });
  card.mount("#card-element");

  return {
    stripe: stripe,
    card: card,
    clientSecret: data.clientSecret
  };
};

/*
 * Collect card details and pay for the order
 */
var pay = function(stripe, card) {
  changeLoadingState(true);

  // Create a token with the card details
  stripe
    .createToken(card)
    .then(function(result) {
      if (result.error) {
        showError(result.error.message);
      } else {
        orderData.token = result.token.id;

        return fetch("/pay", {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify(orderData)
        });
      }
    })
    .then(function(result) {
      return result.json();
    })
    .then(function(paymentData) {
      if (paymentData.error) {
        // The card was declined by the bank
        // Show error and request new card
        showError(paymentData.error);
      } else {
        orderComplete(paymentData);
      }
    });
};

/* ------- Post-payment helpers ------- */

/* Shows a success / error message when the payment is complete */
var orderComplete = function(charge) {
  var chargeJson = JSON.stringify(charge, null, 2);

  document.querySelector(".sr-payment-form").classList.add("hidden");
  document.querySelector("pre").textContent = chargeJson;

  document.querySelector(".sr-result").classList.remove("hidden");
  setTimeout(function() {
    document.querySelector(".sr-result").classList.add("expand");
  }, 200);

  changeLoadingState(false);
};

var showError = function(errorMsgText) {
  changeLoadingState(false);
  var errorMsg = document.querySelector(".sr-field-error");
  errorMsg.textContent = errorMsgText;
  setTimeout(function() {
    errorMsg.textContent = "";
  }, 4000);
};

// Show a spinner on payment submission
var changeLoadingState = function(isLoading) {
  if (isLoading) {
    document.querySelector("button").disabled = true;
    document.querySelector("#spinner").classList.remove("hidden");
    document.querySelector("#button-text").classList.add("hidden");
  } else {
    document.querySelector("button").disabled = false;
    document.querySelector("#spinner").classList.add("hidden");
    document.querySelector("#button-text").classList.remove("hidden");
  }
};
