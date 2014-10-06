//
//  JoinViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/5/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "JoinViewController.h"
#import "PaymentViewController.h"
#import <Parse/Parse.h>

@interface JoinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentMembersLabel;

@property (nonatomic) int amount;

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
    self.navigationItem.title = @"Join Match";
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query getObjectInBackgroundWithId:self.gameID block:^(PFObject *object, NSError *error) {
        self.amount = [[object objectForKey:@"moneyPerPlayer"] intValue];
        NSLog(@"%d", self.amount);
        
        NSArray *currentPlayers = [object objectForKey:@"ApprovedPlayers"];
        int count = (int)[currentPlayers count];
        NSLog(@"%d", count);
        
        NSString *adminPlayer = [object objectForKey:@"Admin"];
        NSLog(@"%@", adminPlayer);
        
        NSNumber *duration = [object objectForKey:@"Time"];
        NSLog(@"%@", duration);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.amountLabel setText:[NSString stringWithFormat:@"%d", self.amount]];
            [self.durationLabel setText:[NSString stringWithFormat:@"%@", duration]];
            [self.inviteLabel setText:adminPlayer];
            [self.currentMembersLabel setText:[NSString stringWithFormat:@"%d", count]];
        });
    }];
    
}
- (IBAction)joinMatch:(id)sender
{
    PaymentViewController *pay = [[PaymentViewController alloc] init];
    pay.gameID = self.gameID;
    pay.amount = self.amount;
    [self.navigationController presentViewController:pay animated:YES completion:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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
