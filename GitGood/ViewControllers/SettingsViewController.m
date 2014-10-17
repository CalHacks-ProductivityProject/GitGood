//
//  SettingsViewController.m
//  GitGood
//
//  Created by Stephen Meriwether on 10/6/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocalGitGoodUser.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController () <UIActionSheetDelegate>

// For use in Storyboard
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *accountDetail;
@property (weak, nonatomic) IBOutlet UILabel *passwordDetail;

@end

@implementation SettingsViewController


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self setupUI];

}

- (void)setupUI
{
    self.accountDetail.text = [[LocalGitGoodUser sharedInstance] username];
    
    // self.password is your password string
    NSMutableString *dottedPassword = [NSMutableString new];
    
    for (int i = 0; i < [[[LocalGitGoodUser sharedInstance] password] length]; i++)
    {
        [dottedPassword appendString:@"●"]; // BLACK CIRCLE Unicode: U+25CF, UTF-8: E2 97 8F
    }
    
    self. passwordDetail.text = dottedPassword;
}

- (void)setupNavBar
{
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:49/255.0 green:136/255.0 blue:201/255.0 alpha:1.0]];
    
    [self.doneButton setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
}


#pragma mark - Action Methods

- (IBAction)dissmissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HERE With Row: %ld and Section: %ld", (long)indexPath.row, (long)indexPath.section);
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self logOutActionSheet];
    }
    else if (indexPath.section == 0 && indexPath.row == 1) {
        [self logOutActionSheet];
    }
    else if (indexPath.section == 2 && indexPath.row == 2) {
        NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=xxxxxxxx&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@", @"Failed to open url:", [url description]);
        }
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        [self deleteDataActionSheet];
    }
}

- (void)deleteDataActionSheet
{
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"WARNING!" message:@"This action can not be undone. You will be automatically disqualified from all of your matches." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        NSLog(@"Cancel Action");
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        NSLog(@"DeleteAction Action");
        [self deleteParseData];
        [self logoutOfGithub];
    }];
    
    [deleteAlert addAction:cancelAction];
    [deleteAlert addAction:deleteAction];
    
    [self presentViewController:deleteAlert animated:YES completion:nil];
}

- (void)logOutActionSheet {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        NSLog(@"Cancel Action");
    }];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        NSLog(@"Logout Action");
        [self logoutOfGithub];
    }];
    
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:logoutAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)deleteParseData
{
    PFObject *user = [PFObject objectWithoutDataWithClassName:@"userInfo" objectId:[[LocalGitGoodUser sharedInstance] parseObjectID]];
    [user deleteInBackground];
}

- (void)logoutOfGithub
{
    [[LocalGitGoodUser sharedInstance] setGithubUsername:nil];
    [[LocalGitGoodUser sharedInstance] setGithubPassword:nil];
    
    LogInViewController *newLogin = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:newLogin animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"Here");
}




@end
