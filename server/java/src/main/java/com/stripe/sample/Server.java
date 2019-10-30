package com.stripe.sample;

import static spark.Spark.get;
import static spark.Spark.port;
import static spark.Spark.post;
import static spark.Spark.staticFiles;

import java.nio.file.Paths;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.stripe.Stripe;
import com.stripe.exception.CardException;
import com.stripe.model.Charge;
import com.stripe.param.ChargeCreateParams;

import io.github.cdimascio.dotenv.Dotenv;

public class Server {
    private static Gson gson = new Gson();

    static class StripeKeyResponse {
        private String publicKey;

        public StripeKeyResponse(String publicKey) {
            this.publicKey = publicKey;
        }
    }

    static class PayRequestBody {
        @SerializedName("items")
        Object[] items;
        @SerializedName("token")
        String token;

        public Object[] getItems() {
            return items;
        }

        public String getToken() {
            return token;
        }

    }

    static class PayResponseBody {
        private Charge charge;
        private String error;

        public PayResponseBody() {

        }

        public void setCharge(Charge charge) {
            this.charge = charge;
        }

        public void setError(String error) {
            this.error = error;
        }
    }

    static Long calculateOrderAmount(Object[] items) {
        // Replace this constant with a calculation of the order's amount
        // Calculate the order total on the server to prevent
        // users from directly manipulating the amount on the client
        return new Long(1400);
    }

    public static void main(String[] args) {
        port(4242);
        Dotenv dotenv = Dotenv.load();
        Stripe.apiKey = dotenv.get("STRIPE_SECRET_KEY");

        staticFiles.externalLocation(
                Paths.get(Paths.get("").toAbsolutePath().toString(), dotenv.get("STATIC_DIR")).normalize().toString());

        get("/stripe-key", (request, response) -> {
            response.type("application/json");
            // Send publishable key to client
            return gson.toJson(new StripeKeyResponse(dotenv.get("STRIPE_PUBLISHABLE_KEY")));
        });

        post("/pay", (request, response) -> {
            PayRequestBody postBody = gson.fromJson(request.body(), PayRequestBody.class);

            ChargeCreateParams createParams = new ChargeCreateParams.Builder()
                    .setAmount(calculateOrderAmount(postBody.getItems())).setCurrency("usd")
                    .setSource(postBody.getToken()).build();
            PayResponseBody responseBody = new PayResponseBody();
            try {
                Charge charge = Charge.create(createParams);
                
                // That's it! You're done! The payment was processed
                responseBody.setCharge(charge);
            } catch (CardException e) {
                // Handle "hard declines" e.g. insufficient funds, expired card, etc
                // See https://stripe.com/docs/declines/codes for more
                responseBody.setError(e.getMessage());
            }

            return gson.toJson(responseBody);
        });
    }
}
