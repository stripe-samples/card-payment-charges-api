//
//  CheckoutViewController.swift
//  app
//
//  Created by Yuki Tokuhiro on 9/25/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

import UIKit
import Stripe

/**
 This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment-charges#ios

 To run this app, follow the steps here https://github.com/stripe-samples/card-payment-charges-api#how-to-run-locally
*/
let BackendUrl = "http://127.0.0.1:4242/"

class CheckoutViewController: UIViewController {
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        return cardTextField
    }()
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Pay", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2),
        ])
    }

    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: "Restart demo", style: .cancel) { _ in
                    self.cardTextField.clear()
                })
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc
    func pay() {
        // Create an STPCardParams instance
        let cardParams = STPCardParams()
        cardParams.number = cardTextField.cardNumber
        cardParams.expMonth = cardTextField.expirationMonth
        cardParams.expYear = cardTextField.expirationYear
        cardParams.cvc = cardTextField.cvc

        // Pass it to STPAPIClient to create a Token
        STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
            guard let token = token else {
                // Handle the error
                return
            }
            // Send the token identifier to your server
            let tokenID = token.tokenId
            
            let url = URL(string: BackendUrl + "pay")!
            let json: [String: Any] = [
                "currency": "usd",
                "items": [
                    "id": "photo_subscription"
                ],
                "token": tokenID
            ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                        let message = error?.localizedDescription ?? "Failed to decode response from server."
                        self?.displayAlert(title: "Error creating Charge", message: message)
                        return
                }
                
                if let chargeError = json["error"] as? String {
                    self?.displayAlert(title: "Payment failed", message: chargeError)
                } else {
                    self?.displayAlert(title: "Success", message: "Payment succeeded!", restartDemo: true)
                }
                
            })
            task.resume()
        }
    }
}

extension CheckoutViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

// docs_window_spec {"setup-ui-swift": [[21, 51], [52, 53], ["// ..."], [131, 132]]}
