package com.example.app;

import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.stripe.android.ApiResultCallback;
import com.stripe.android.PaymentConfiguration;
import com.stripe.android.PaymentIntentResult;
import com.stripe.android.Stripe;
import com.stripe.android.model.Card;
import com.stripe.android.model.ConfirmPaymentIntentParams;
import com.stripe.android.model.PaymentIntent;
import com.stripe.android.model.PaymentMethodCreateParams;
import com.stripe.android.model.Token;
import com.stripe.android.view.CardInputWidget;

import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.lang.reflect.Type;
import java.util.Dictionary;
import java.util.Map;
import java.util.Objects;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class CheckoutActivity extends AppCompatActivity {
    /**
     * This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment#android
     * <p>
     * To run this app, follow the steps here: https://github.com/stripe-samples/mobile-elements-card-payment#how-to-run
     */
    // 10.0.2.2 is the Android emulator's alias to localhost
    private static final String BACKEND_URL = "http://10.0.2.2:4242/";

    private OkHttpClient httpClient = new OkHttpClient();
    private Stripe stripe;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checkout);

        // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
        // ⚠️ Don't forget to switch this to your live-mode publishable key before publishing your app
        PaymentConfiguration.init(getApplicationContext(), "Insert your publishable key"); // Get your key here: https://stripe.com/docs/keys#obtain-api-keys

        // Hook up the pay button to the card widget and stripe instance
        Button payButton = findViewById(R.id.payButton);
        WeakReference<CheckoutActivity> weakActivity = new WeakReference<>(this);
        payButton.setOnClickListener((View view) -> {
            // Get the card details from the card widget
            CardInputWidget cardInputWidget = findViewById(R.id.cardInputWidget);
            Card card = cardInputWidget.getCard();
            if (card != null) {
                // Create a Stripe Token from the card details
                stripe = new Stripe(getApplicationContext(), PaymentConfiguration.getInstance(getApplicationContext()).getPublishableKey());
                stripe.createToken(card, new ApiResultCallback<Token>() {
                    @Override
                    public void onSuccess(@NonNull Token result) {
                        // Send the token identifier to the server
                        MediaType mediaType = MediaType.get("application/json; charset=utf-8");
                        String json = "{"
                                + "\"currency\":\"usd\","
                                + "\"items\":["
                                + "{\"id\":\"photo_subscription\"}"
                                + "],"
                                + "\"token\":\"" + result.getId() + "\""
                                + "}";
                        RequestBody body = RequestBody.create(json, mediaType);
                        Request request = new Request.Builder()
                                .url(BACKEND_URL + "create-payment-intent")
                                .post(body)
                                .build();
                        httpClient.newCall(request)
                                .enqueue(new Callback() {
                                    @Override
                                    public void onFailure(@NotNull Call call, @NotNull IOException e) {
                                        weakActivity.get().displayAlert("Failed to decode response from server", e.getLocalizedMessage(), false);
                                    }

                                    @Override
                                    public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                                        Gson gson = new Gson();
                                        Type type = new TypeToken<Map<String, String>>() {
                                        }.getType();
                                        Map<String, String> responseMap = gson.fromJson(
                                                Objects.requireNonNull(response.body()).string(),
                                                type
                                        );
                                        String error = responseMap.get("error");
                                        if (error != null) {
                                            weakActivity.get().displayAlert("Payment failed", error, false);
                                        } else {
                                            weakActivity.get().displayAlert("Success", "Payment succeeded!", true);
                                        }
                                    }
                                });

                    }

                    @Override
                    public void onError(@NonNull Exception e) {
                        weakActivity.get().displayAlert("Failed to decode response from server", e.getLocalizedMessage(), false);
                    }
                });
            }
        });
    }

    private void displayAlert(@NonNull String title,
                              @Nullable String message,
                              boolean restartDemo) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setTitle(title)
                .setMessage(message);
        if (restartDemo) {
            builder.setPositiveButton("Restart demo",
                    (DialogInterface dialog, int index) -> {
                        CardInputWidget cardInputWidget = findViewById(R.id.cardInputWidget);
                        cardInputWidget.clear();
                    });
        } else {
            builder.setPositiveButton("Ok", null);
        }
        builder.create().show();
    }
}
