//
//  LeaderboardViewController.h
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController

@property (nonatomic, assign) NSString *gameID;
@property (nonatomic, strong) NSMutableArray *players;

@end
