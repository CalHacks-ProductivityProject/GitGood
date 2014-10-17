//
//  PasscodeSettingsViewController.m
//  GitGood
//
//  Created by Stephen Meriwether on 10/16/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "PasscodeSettingsViewController.h"
#import "ABPadLockScreenSetupViewController.h"
#import "ABPadLockScreenViewController.h"
#import "ABPadButton.h"
#import "ABPinSelectionView.h"

@interface PasscodeSettingsViewController() <ABPadLockScreenViewControllerDelegate, ABPadLockScreenSetupViewControllerDelegate>

// For use in Storyboards
@property (weak, nonatomic) IBOutlet UISwitch *requirePasscode;
@property (weak, nonatomic) IBOutlet UISwitch *useTouchID;

// Utilities
@property (nonatomic, copy) NSString *thePin;

@end

@implementation PasscodeSettingsViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [self.navigationController setTitle:@"Passcode"];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
}


#pragma mark - Action Methods

- (IBAction)requirePasscodeStateChange:(id)sender
{
    ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:YES];
    
    lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
    lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    lockScreen.view.backgroundColor = [UIColor clearColor];
    
    [self presentViewController:lockScreen animated:YES completion:nil];
}

- (IBAction)touchIDStateChange:(id)sender
{
    
}

#pragma mark - ABLockScreenDelegate Methods

- (BOOL)padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController validatePin:(NSString*)pin;
{
    NSLog(@"Validating pin %@", pin);
    
    return [self.thePin isEqualToString:pin];
}

- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Pin entry successfull");
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    NSLog(@"Failed attempt number %ld with pin: %@", (long)attemptNumber, falsePin);
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Pin entry cancelled");
}

#pragma mark - ABPadLockScreenSetupViewControllerDelegate Methods
- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)padLockScreenViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.thePin = pin;
    NSLog(@"Pin set to pin %@", self.thePin);
}

@end
