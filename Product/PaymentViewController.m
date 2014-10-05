//
//  PaymentViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/5/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "PaymentViewController.h"
#import "PayPalMobile.h"

@interface PaymentViewController () <PayPalPaymentDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@end

@implementation PaymentViewController

- (instancetype) init {
    self = [super init];
    if (self) {
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
        
        // See PayPalConfiguration.h for details and default values.
        // Should you wish to change any of the values, you can do so here.
        // For example, if you wish to accept PayPal but not payment card payments, then add:
        _payPalConfiguration.acceptCreditCards = NO;
        // Or if you wish to have the user choose a Shipping Address from those already
        // associated with the user's PayPal account, then add:
        _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Start out working with the mock environment. When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    // Amount, currency, and description
    NSString *amount = [NSString stringWithFormat:@"%d", self.amount];
    payment.amount = [[NSDecimalNumber alloc] initWithString:amount];
    payment.currencyCode = @"USD";
    payment.shortDescription = self.gameID;
    
    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture.
    // To perform Authorization only, and defer Capture to your server,
    // use PayPalPaymentIntentAuthorize.
    // To place an Order, and defer both Authorization and Capture to
    // your server, use PayPalPaymentIntentOrder.
    // (PayPalPaymentIntentOrder is valid only for PayPal payments, not credit card payments.)
    payment.intent = PayPalPaymentIntentSale;
    
    // If your app collects Shipping Address information from the customer,
    // or already stores that information on your server, you may provide it here.
    //payment.shippingAddress = address; // a previously-created PayPalShippingAddress object
    
    
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:self.payPalConfiguration
                                                                        delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self.navigationController presentViewController:paymentViewController animated:YES completion:nil];
    
    

    
    /*
    PayPalFuturePaymentViewController *fpViewController;
    fpViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfiguration
                                                                               delegate:self];
    
    
    
    // Present the PayPalFuturePaymentViewController
    [self presentViewController:fpViewController animated:YES completion:nil];
     */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
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

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
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
