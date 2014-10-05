//
//  PaymentViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/5/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "PaymentViewController.h"
#import "PayPalMobile.h"

@interface PaymentViewController () <PayPalFuturePaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@end

@implementation PaymentViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
        
        // See PayPalConfiguration.h for details and default values.
        
        // Minimally, you will need to set three merchant information properties.
        // These should be the same values that you provided to PayPal when you registered your app.
        _payPalConfiguration.merchantName = self.gameID;
        _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.omega.supreme.example/privacy"];
        _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.omega.supreme.example/user_agreement"];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Start out working with the mock environment. When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    
    PayPalFuturePaymentViewController *fpViewController;
    fpViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfiguration
                                                                               delegate:self];
    
    // Present the PayPalFuturePaymentViewController
    [self presentViewController:fpViewController animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    // User cancelled login. Dismiss the PayPalLoginViewController, breathe deeply.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    // The user has successfully logged into PayPal, and has consented to future payments.
    
    // Your code must now send the authorization response to your server.
    [self sendAuthorizationToServer:futurePaymentAuthorization];
    
    // Be sure to dismiss the PayPalLoginViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAuthorizationToServer:(NSDictionary *)authorization {
    // Send the entire authorization reponse
    NSData *consentJSONData = [NSJSONSerialization dataWithJSONObject:authorization
                                                              options:0
                                                                error:nil];
    
    // (Your network code here!)
    //
    // Send the authorization response to your server, where it can exchange the authorization code
    // for OAuth access and refresh tokens.
    //
    // Your server must then store these tokens, so that your server code can execute payments
    // for this user in the future.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
