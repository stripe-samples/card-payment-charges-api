package com.example.app

import java.io.IOException
import java.lang.ref.WeakReference

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody

import org.json.JSONObject

import com.stripe.android.ApiResultCallback
import com.stripe.android.Stripe
import com.stripe.android.view.CardInputWidget
import com.stripe.android.PaymentConfiguration
import com.stripe.android.model.*


class CheckoutActivityKotlin : AppCompatActivity() {

    /**
     * This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment-charges#android
     *
     * To run this app, follow the steps here: https://github.com/stripe-samples/card-payment-charges-api#how-to-run-locally
     */
    // 10.0.2.2 is the Android emulator's alias to localhost
    private val backendUrl = "http://10.0.2.2:4242/"
    private val httpClient = OkHttpClient()
    private lateinit var stripe: Stripe

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_checkout)

        // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
        // ⚠️ Don't forget to switch this to your live-mode publishable key before publishing your app
        PaymentConfiguration.init(applicationContext, "Insert your publishable key") // Get your key here: https://stripe.com/docs/keys#obtain-api-keys

        // Hook up the pay button to the card widget and stripe instance
        val payButton: Button = findViewById(R.id.payButton)
        val weakActivity = WeakReference<Activity>(this@CheckoutActivityKotlin)
        payButton.setOnClickListener {
            // Get the card details from the card widget
            val cardInputWidget =
                findViewById<CardInputWidget>(R.id.cardInputWidget)
            cardInputWidget.card?.let { card ->
                // Create a Stripe Token from the card details
                stripe = Stripe(applicationContext, PaymentConfiguration.getInstance(applicationContext).publishableKey)
                stripe.createToken(card, object: ApiResultCallback<Token> {
                    override fun onSuccess(result: Token) {
                        // Send the Token identifier to the server
                        val mediaType = "application/json; charset=utf-8".toMediaType()
                        val json = """
                            {
                                "currency":"usd",
                                "items": [
                                    {"id":"photo_subscription"}
                                ],
                                "token": "${result.id}"
                            }
                            """
                        val body = json.toRequestBody(mediaType)
                        val request = Request.Builder()
                            .url(backendUrl + "pay")
                            .post(body)
                            .build()
                        httpClient.newCall(request)
                            .enqueue(object: Callback {
                                override fun onFailure(call: Call, e: IOException) {
                                    displayAlert(weakActivity.get(), "Failed to decode response from server", "Error: $e")
                                }

                                override fun onResponse(call: Call, response: Response) {
                                    if (!response.isSuccessful) {
                                        displayAlert(weakActivity.get(), "Failed to decode response from server", "Error: $response")
                                    } else {
                                        val responseData = response.body?.string()
                                        var responseJSON = JSONObject(responseData)
                                        val error = responseJSON.optString("error", null)
                                        if (error != null) {
                                            displayAlert(weakActivity.get(), "Payment failed", error)
                                        } else {
                                            displayAlert(weakActivity.get(), "Success", "Payment succeeded!", true)
                                        }
                                    }
                                }
                            })
                    }

                    override fun onError(e: java.lang.Exception) {
                        displayAlert(weakActivity.get(), "Error", e.localizedMessage)
                    }
                })
            }

        }
    }

    private fun displayAlert(activity: Activity?, title: String, message: String, restartDemo: Boolean = false) {
        if (activity == null) {
            return
        }
        runOnUiThread {
            val builder = AlertDialog.Builder(activity)
            builder.setTitle(title)
            builder.setMessage(message)
            if (restartDemo) {
                builder.setPositiveButton("Restart demo") { _, _ ->
                    val cardInputWidget =
                        findViewById<CardInputWidget>(R.id.cardInputWidget)
                    cardInputWidget.clear()
                }
            }
            else {
                builder.setPositiveButton("Ok", null)
            }
            val dialog = builder.create()
            dialog.show()
        }
    }
}
