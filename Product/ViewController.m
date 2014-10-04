//
//  ViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "ViewController.h"
#import "LogInViewController.h"
#import "User.h"
#import <Product-Swift.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *challengesTable;
@property (nonatomic, copy) NSString *githubUsername;

// !!!  DELETE LATER  !!!
@property (nonatomic) NSMutableArray *testChallenges;
@property (nonatomic) NSMutableArray *testMembers;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLogIn"]) {
        [self displayLoginScreen];
    }
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (int i = 0; i < 10; i++) {
        User *user = [[User alloc] init];
        user.githubUsername = [NSString stringWithFormat:@"%d%@", i, @"user"];
        [self.testMembers addObject:user];
    }
    

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:49/255.0 green:136/255.0 blue:201/255.0 alpha:1.0]];
    [self.navigationController setTitle:self.githubUsername];
    
    self.testChallenges = [[NSMutableArray alloc] init];
    
    self.challengesTable.delegate = self;
    self.challengesTable.dataSource = self;
    
    UserProfile *profile = [UserProfile newInstance];
    
    //[profile retrieveURLString:@"PeterKaminski09"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addRow:(id)sender
{
    [self.testChallenges addObject:@"Hello"];
    [self.challengesTable reloadData];
    [self.challengesTable setHidden:NO];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.testChallenges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.testChallenges objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


#pragma mark - Login Screen

- (void) displayLoginScreen
{
    NSLog(@"Here");
    LogInViewController *logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    logIn.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:logIn animated:YES completion:Nil];
    
    logIn.somethingHappenedInModalVC = ^(NSString *response) {
        self.githubUsername = response;
        
        [self addRow:nil];
        [self addRow:nil];
    };
    
    [self.challengesTable reloadData];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"TESTING");
    if ([segue.identifier isEqualToString:@"CreateMatchSegue"]) {
        NSLog(@"here");
    }
}

@end
