//
//  SettingsViewController.m
//  GitGood
//
//  Created by Stephen Meriwether on 10/6/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

// For use in Storyboard
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:49/255.0 green:136/255.0 blue:201/255.0 alpha:1.0]];
    
    [self.doneButton setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dissmissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupSupportSection
{
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
