//
//  LeaderboardViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "LeaderboardViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Parse/Parse.h>
#import <Product-Swift.h>

@interface LeaderboardViewController () <UITableViewDelegate, UITableViewDataSource>

// For use in Storyboards
@property (weak, nonatomic) IBOutlet UITableView *leaderboardTable;
@property (strong, atomic) PFObject *clone;

@end

@implementation LeaderboardViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.title = @"Leaderboards";
    
    NSLog(@"GameID in Leaderboard:%@", _gameID);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.title = @"Leaderboards";
    
    self.leaderboardTable.delegate = self;
    self.leaderboardTable.dataSource = self;
    
    //self.leaderboardTable.tableFooterView = [UIView new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query getObjectInBackgroundWithId:self.gameID block:^(PFObject *object, NSError *error) {
        
        self.players = [object objectForKey:@"ApprovedPlayers"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.leaderboardTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
    
    NSLog(@"We got here");
    for (int i=0; i<[_players count]; ++i)
        NSLog(@"%@", [_players objectAtIndex:i]);
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *rightDetailIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDetailIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rightDetailIdentifier];
    }
    
    //cell.textLabel.text = [self.testChallenges objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.players objectAtIndex:indexPath.row];
    
    UIImage *cellImage = [UIImage imageNamed:@"7351237"];
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cellImage drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //cell.detailTextLabel.text = @"100 Lines";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
