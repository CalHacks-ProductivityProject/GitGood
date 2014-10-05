//
//  StartChallengeViewController.h
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartChallengeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *enterMoney;
@property (strong, nonatomic) NSNumberFormatter *formatter;
@property (nonatomic, assign) float movedPosition;
@property (nonatomic, assign) float defaultPosition;

@end
