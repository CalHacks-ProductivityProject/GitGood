//
//  SettingsViewController.m
//  GitGood
//
//  Created by Stephen Meriwether on 10/6/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocalGitGoodUser.h"

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
}


#pragma mark - Action Methods

- (IBAction)dissmissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logOutActionSheet {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log Out", nil];
    
    [[UICollectionView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor redColor]];
    
    [actionSheet showInView:self.view];
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HERE With Row: %ld and Section: %ld", (long)indexPath.row, (long)indexPath.section);
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self logOutActionSheet];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"Here");
}




@end
