//
//  AppDelegate.swift
//  app
//
//  Created by Ben Guo on 9/27/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

import UIKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
        // ⚠️ Don't forget to switch this to your live-mode publishable key before publishing your app
        Stripe.setDefaultPublishableKey(<# Insert your Stripe publishable key #>) // Get your key here: https://stripe.com/docs/keys#obtain-api-keys
        let window = UIWindow(frame: UIScreen.main.bounds)
        let checkoutViewController = CheckoutViewController();
        let rootViewController = UINavigationController(rootViewController: checkoutViewController)
        rootViewController.navigationBar.isTranslucent = false
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

}

