//
//  LogInViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "LogInViewController.h"
#import "OctoKit.h"
#import <Parse/Parse.h>


@interface LogInViewController () <UITextFieldDelegate>

// For use in Storyboards
@property (weak, nonatomic) IBOutlet UITextField *githubUsername;
@property (weak, nonatomic) IBOutlet UITextField *githubPassword;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.githubUsername.delegate = self;
    self.githubPassword.delegate = self;
    
}

- (IBAction)continueBUtton:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLogIn"];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Account Auth

- (IBAction)authGithubAccount:(id)sender
{
    [OCTClient setClientID:@"84a73422fec4389f37e6" clientSecret:@"5c62c44cefb8b4a0b51d84531de3aa49e9cd3c2d"];
    OCTUser *user = [OCTUser userWithRawLogin:self.githubUsername.text server:OCTServer.dotComServer];
    [[OCTClient
      signInAsUser:user password:self.githubPassword.text oneTimePassword:nil scopes:OCTClientAuthorizationScopesUser]
     subscribeNext:^(OCTClient *authenticatedClient) {
         // Authentication was successful. Do something with the created client.
         [self createAccount:self.githubUsername.text];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLogIn"];
         self.somethingHappenedInModalVC(self.githubUsername.text);
         [self dismissViewControllerAnimated:YES completion:nil];
         
         [self saveString:user.rawLogin forKey:@"login"];
         [self saveString:authenticatedClient.token forKey:@"token"];


     } error:^(NSError *error) {
         // Authentication failed.s
         dispatch_async(dispatch_get_main_queue(), ^{
            [self shakeAnimation:self.githubPassword];
         });
         
         NSLog(@"Oops: %@", error);
     }];
}

- (void)createAccount:(NSString*)username
{
    //Check for duplicates
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    PFQuery *queryForMatch = [PFQuery queryWithClassName:@"userInfo"];
    [queryForMatch whereKeyExists:@"username"];
    [queryForMatch whereKey:@"username" equalTo:username];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:username forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    NSArray *results = [queryForMatch findObjects];
    
    if ([results count] == 0)
    {
        PFObject *userInfo = [PFObject objectWithClassName:@"userInfo"];
        userInfo[@"username"] = username;
        //[userInfo addObject:NULL forKey:@"PendingGames"];
        //[userInfo addObject:NULL forKey:@"CurrentGames"];
        [userInfo saveInBackground];
    }
    else
        NSLog(@"%@ already exists!\n", username);
}

-(void)shakeAnimation:(UIView*) view {
    const int reset = 5;
    const int maxShakes = 6;
    
    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{view.transform = CGAffineTransformMakeTranslation(translate, 0);}
                     completion:^(BOOL finished){
                         if(shakes < maxShakes){
                             shakes++;
                             
                             //throttle down movement
                             if (translate>0)
                                 translate--;
                             
                             //change direction
                             translate*=-1;
                             [self shakeAnimation:view];
                         } else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             return;
                         }
                     }];

}

- (void)saveString:(NSString *)inputString forKey:(NSString	*)account {
    NSAssert(account != nil, @"Invalid account");
    NSAssert(inputString != nil, @"Invalid string");
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (error == errSecSuccess) {
        // do update
        NSDictionary *attributesToUpdate = [NSDictionary dictionaryWithObject:[inputString dataUsingEncoding:NSUTF8StringEncoding]
                                                                       forKey:(__bridge id)kSecValueData];
        
        error = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
        
        NSAssert1(error == errSecSuccess, @"SecItemUpdate failed: %d", (int)error);
    } else if (error == errSecItemNotFound) {
        // do add
        [query setObject:[inputString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        
        error = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        NSAssert1(error == errSecSuccess, @"SecItemAdd failed: %d", (int)error);
    } else {
        NSAssert1(NO, @"SecItemCopyMatching failed: %d", (int)error);
    }
}

@end
