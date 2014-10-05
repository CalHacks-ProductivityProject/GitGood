//
//  ViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "ViewController.h"
#import "LogInViewController.h"
#import "StartChallengeViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import <Product-Swift.h>
#import "JoinViewController.h"
#import "LeaderboardViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *challengesTable;
@property (nonatomic, copy) NSString *githubUsername;
@property (weak, nonatomic) IBOutlet UIImageView *fillerImage;
@property (weak, nonatomic) IBOutlet UILabel *fillerLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedButton;
@property (nonatomic) NSMutableArray *userChallenges;
// !!!  DELETE LATER  !!!
@property (nonatomic) NSMutableArray *testMembers;


@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLogIn"]) {
        [self displayLoginScreen];
    }
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                if ([[object objectForKey:@"ApprovedPlayers"] containsObject:username]) {
                    if (![self.userChallenges containsObject:[object objectId]]) {
                        [self.userChallenges addObject:[object objectId]];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.userChallenges) {
                    [self.challengesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

                    [self showTable];
                }
            });
        }
    }];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self reAuthGithub];
    

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:49/255.0 green:136/255.0 blue:201/255.0 alpha:1.0]];
    
    self.userChallenges = [[NSMutableArray alloc] init];
    
    self.challengesTable.delegate = self;
    self.challengesTable.dataSource = self;
    
    [self showTable];
    
    //UserProfile *profile = [UserProfile newInstance];
    //[profile retrieveURLString:@"smeriwether"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userChallenges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.userChallenges objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"Number of Users: 4";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


#pragma mark - Login Screen

- (void) displayLoginScreen
{
    LogInViewController *logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    logIn.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:logIn animated:YES completion:Nil];
    
    logIn.somethingHappenedInModalVC = ^(NSString *response) {
        self.githubUsername = response;
    };
    
    [self.challengesTable reloadData];
    
}

- (void)reAuthGithub
{
    
    
    
    //OCTUser *user = [OCTUser userWithRawLogin:[self getStringForKey:@"login"]; server:OCTServer.dotComServer];
    //OCTClient *client = [OCTClient authenticatedClientWithUser:user token:[self getStringForKey:@"token"]];
}

- (void)showTable
{
    if ([self.userChallenges count] > 0) {
        [self.fillerImage setHidden:YES];
        [self.fillerImage setImage:nil];
        [self.fillerLabel setHidden:YES];
        [self.challengesTable setHidden:NO];
    }
}

- (IBAction)indexChage:(UISegmentedControl*)sender
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    switch (sender.selectedSegmentIndex)
    {
        case 0:
        {
            self.userChallenges = nil;
            self.userChallenges = [[NSMutableArray alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.challengesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self showTable];
            });
            
            PFQuery *query = [PFQuery queryWithClassName:@"Game"];
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *object in objects) {
                        if ([[object objectForKey:@"ApprovedPlayers"] containsObject:username]) {
                            if (![self.userChallenges containsObject:[object objectId]]) {
                                [self.userChallenges addObject:[object objectId]];
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                            [self.challengesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                            
                            [self showTable];
                    });
                }
            }];
            break;
        }
        case 1:
        {
            NSLog(@"Here");
            self.userChallenges = nil;
            self.userChallenges = [[NSMutableArray alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.challengesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [self showTable];
            });
            
            PFQuery *query = [PFQuery queryWithClassName:@"Game"];
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *object in objects) {
                        if ([[object objectForKey:@"PendingPlayers"] containsObject:username]) {
                            if (![self.userChallenges containsObject:[object objectId]]) {
                                [self.userChallenges addObject:[object objectId]];
                            }
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                            [self.challengesTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                            [self showTable];
                    });
                }
            }];
            
            break;
        }
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedButton.selectedSegmentIndex)
    {
        case 0:
        {
            UITabBarController *tab = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            [self.navigationController pushViewController:tab animated:YES];
            break;
        }
        case 1:
        {
            JoinViewController *join = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinViewController"];
            join.gameID = [self.userChallenges objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:join animated:YES];
            break;
        }
    }
}


@end
