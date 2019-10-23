//
//  CheckoutViewController.m
//  app
//
//  Created by Ben Guo on 9/29/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

#import "CheckoutViewController.h"
#import <Stripe/Stripe.h>

/**
 This example collects card payments, implementing the guide here: https://stripe.com/docs/payments/accept-a-payment-charges#ios

 To run this app, follow the steps here https://github.com/stripe-samples/card-payment-charges-api#how-to-run-locally
*/
NSString *const BackendUrl = @"http://127.0.0.1:4242/";

@interface CheckoutViewController ()

@property (nonatomic, weak) STPPaymentCardTextField *cardTextField;
@property (nonatomic, weak) UIButton *payButton;

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Set up the Stripe card text field
    STPPaymentCardTextField *cardTextField = [[STPPaymentCardTextField alloc] init];
    self.cardTextField = cardTextField;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor systemBlueColor];
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    [button setTitle:@"Pay" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    self.payButton = button;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cardTextField, button]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.spacing = 20;
    [self.view addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.leftAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.leftAnchor multiplier:2],
        [self.view.rightAnchor constraintEqualToSystemSpacingAfterAnchor:stackView.rightAnchor multiplier:2],
        [stackView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor multiplier:2],
    ]];
}

- (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message restartDemo:(BOOL)restartDemo {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (restartDemo) {
            [alert addAction:[UIAlertAction actionWithTitle:@"Restart demo" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.cardTextField clear];
            }]];
        }
        else {
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)pay {
    // Create an STPCardParams instance
    STPCardParams *cardParams = [STPCardParams new];
    cardParams.number = self.cardTextField.cardNumber;
    cardParams.expMonth = self.cardTextField.expirationMonth;
    cardParams.expYear = self.cardTextField.expirationYear;
    cardParams.cvc = self.cardTextField.cvc;

    // Pass it to STPAPIClient to create a Token
    [[STPAPIClient sharedClient] createTokenWithCard:cardParams completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        if (token == nil) {
            [self displayAlertWithTitle:@"Token creation failed" message:error.localizedDescription restartDemo:NO];
            return;
        }
        // Send the token identifier to your server
        NSString *tokenID = token.tokenId;
        
        NSDictionary *json = @{
            @"items": @{@"id": @"photo-subscription"},
            @"currency": @"usd",
            @"token": tokenID
        };
        NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@pay", BackendUrl]];
        NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
            NSError *error = requestError;
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (error != nil || httpResponse.statusCode != 200 || json == nil) {
                NSString *message = error.localizedDescription ?: @"Failed to decode response from server";
                [self displayAlertWithTitle:@"Error creating Charge" message:message restartDemo:NO];
                return;
            }
            
            if (json[@"error"] != nil) {
                [self displayAlertWithTitle:@"Payment failed" message:json[@"error"] restartDemo:NO];
            } else {
                [self displayAlertWithTitle:@"Success" message:@"Payment succeeded!" restartDemo:YES];
            }
        }];
        [task resume];
    }];
}

@end

