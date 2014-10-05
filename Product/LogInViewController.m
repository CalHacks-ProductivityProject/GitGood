//
//  LogInViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "LogInViewController.h"
#import "OctoKit.h"


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
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLogIn"];
         self.somethingHappenedInModalVC(self.githubUsername.text);
         [self dismissViewControllerAnimated:YES completion:nil];
     } error:^(NSError *error) {
         // Authentication failed.
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

@end
