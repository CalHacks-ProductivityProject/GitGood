//
//  TabBarController.m
//  Product
//
//  Created by trineroks on 10/5/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "TabBarViewController.h"
#import "LeaderboardViewController.h"

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
     //Pass the selected object to the new view controller.
    LeaderboardViewController *leaderboard = [segue destinationViewController];
    NSLog(@"GameID in TabBarController:%@", _gameID);
    leaderboard.gameID = _gameID;
}



@end
