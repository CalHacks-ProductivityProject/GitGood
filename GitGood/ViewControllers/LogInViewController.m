//
//  LogInViewController.m
//  Product
//
//  Created by GitGood on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "LogInViewController.h"
#import "OctoKit.h"
#import "LocalGitGoodUser.h"
#import <Parse/Parse.h>


@interface LogInViewController () <UITextFieldDelegate>

// For use in Storyboards
@property (weak, nonatomic) IBOutlet UITextField *githubUsername;
@property (weak, nonatomic) IBOutlet UITextField *githubPassword;

@end

@implementation LogInViewController


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.githubUsername.delegate = self;
    self.githubPassword.delegate = self;
}


#pragma mark - Action Methods

- (IBAction)leaveForGithubAccountCreation:(id)sender
{
    // Add code to show safari github account creaation page
    // URL: https://github.com
}


- (IBAction)authGithubAccount:(id)sender
{
    // OCTClient is the official Github authentication. Client ID and Secrect have been registered for this application.
    // Check dropbox for login information.
    [OCTClient setClientID:@"84a73422fec4389f37e6"
              clientSecret:@"5c62c44cefb8b4a0b51d84531de3aa49e9cd3c2d"];
    OCTUser *user = [OCTUser userWithRawLogin:self.githubUsername.text
                                       server:OCTServer.dotComServer];
    [[OCTClient signInAsUser:user
                    password:self.githubPassword.text
             oneTimePassword:nil
                      scopes:OCTClientAuthorizationScopesUser]
     subscribeNext:^(OCTClient *authenticatedClient) {
         // Authentication was successful.
         
         [self saveInformationWithUsername:self.githubUsername.text password:self.githubPassword.text];
         [self createParseAccount];
         [self dismissViewControllerAnimated:YES completion:nil];
     }
     error:^(NSError *error) {
         
         // Authentication failed. Show shake animation.
         dispatch_async(dispatch_get_main_queue(), ^{
             [self shakeAnimation:self.githubPassword];
         });
         
         NSLog(@"Oops: %@", error);
     }];
}


#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Data Controll Methods

- (void)createParseAccount
{
    
    // Check for duplicates usernames (dont create account if already exists)
    PFQuery *queryForMatch = [PFQuery queryWithClassName:@"userInfo"];
    [queryForMatch whereKeyExists:@"username"];
    [queryForMatch whereKey:@"username" equalTo:[[LocalGitGoodUser sharedInstance] username]];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[[LocalGitGoodUser sharedInstance] username] forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    NSArray *results = [queryForMatch findObjects];
    
    if ([results count] == 0) {
        PFObject *userInfo = [PFObject objectWithClassName:@"userInfo"];
        userInfo[@"username"] = [[LocalGitGoodUser sharedInstance] username];
        [userInfo saveInBackground];
    }
    else {
        NSLog(@"%@ already exists\n", [[LocalGitGoodUser sharedInstance] username]);
    }
}

- (void)saveInformationWithUsername:username password:password
{
    [[LocalGitGoodUser sharedInstance] setGithubUsername:username];
    [[LocalGitGoodUser sharedInstance] setGithubPassword:password];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[LocalGitGoodUser sharedInstance] username] forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[[LocalGitGoodUser sharedInstance] password] forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Animations

- (void)shakeAnimation:(UIView*) view
{
    const int reset = 5;
    const int maxShakes = 6;
    
    //pass these as variables instead of statics or class variables if shaking two controls simultaneously
    static int shakes = 0;
    static int translate = reset;
    
    [UIView animateWithDuration:0.09-(shakes*.01) // reduce duration every shake from .09 to .04
                          delay:0.01f//edge wait delay
                        options:(enum UIViewAnimationOptions) UIViewAnimationCurveEaseInOut
                     animations:^{ view.transform = CGAffineTransformMakeTranslation(translate, 0); }
                     completion:^(BOOL finished){
                         
                         if(shakes < maxShakes){
                             shakes++;
                             
                             //throttle down movement
                             if (translate > 0) {
                                 translate--;
                             }
                             
                             //change direction
                             translate *= -1;
                             [self shakeAnimation:view];
                             
                         }
                         else {
                             view.transform = CGAffineTransformIdentity;
                             shakes = 0;//ready for next time
                             translate = reset;//ready for next time
                             return;
                         }
    }];

}

@end
