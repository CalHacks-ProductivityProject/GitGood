//
//  JoinViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/5/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "JoinViewController.h"
#import <Parse/Parse.h>

@interface JoinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentMembersLabel;

@end

@implementation JoinViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.title = @"Join Match";
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query getObjectInBackgroundWithId:self.gameID block:^(PFObject *object, NSError *error) {
        int amountLabel = [[object objectForKey:@"moneyPerPlayer"] intValue];
        NSLog(@"%d", amountLabel);
        
        NSArray *currentPlayers = [object objectForKey:@"ApprovedPlayers"];
        int count = [currentPlayers count];
        NSLog(@"%d", count);
        
        NSString *adminPlayer = [object objectForKey:@"AdminPlayer"];
        NSLog(@"%@", adminPlayer);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
