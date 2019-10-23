//
//  AppDelegate.m
//  app
//
//  Created by Ben Guo on 9/29/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckoutViewController.h"

@import Stripe;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
    // ⚠️ Don't forget to switch this to your live-mode publishable key before publishing your app
    [Stripe setDefaultPublishableKey:<# Insert your Stripe publishable key here #>]; // Get your key here: https://stripe.com/docs/keys#obtain-api-keys
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIWindow *window = [[UIWindow alloc] initWithFrame:bounds];
    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:checkoutViewController];
    rootViewController.navigationBar.translucent = NO;
    window.rootViewController = rootViewController;
    [window makeKeyAndVisible];
    self.window = window;

    return YES;
}

@end
