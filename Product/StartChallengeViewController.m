//
//  StartChallengeViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "StartChallengeViewController.h"

@interface StartChallengeViewController () <UITextFieldDelegate>

@end

@implementation StartChallengeViewController

- (void)viewDidLoad {
    NSLog(@"Observer added\n");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    self.enterMoney.delegate = self;
    
    _formatter = [NSNumberFormatter new];
    [_formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [_formatter setLenient:YES];
    [_formatter setGeneratesDecimalNumbers:YES];
    
    [self.view addGestureRecognizer:tap];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelNewChallenege:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) dismissKeyboard
{
    [_enterMoney.self resignFirstResponder];
}

const int movedistance = 130;

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y += movedistance;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    // the keyboard is showing so resize the table's height
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y -= movedistance;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSLog(@"Observer removed\n");
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSDecimalNumber *amount = (NSDecimalNumber*) [_formatter numberFromString:replaced];
    if (amount == nil) {
        // Something screwed up the parsing. Probably an alpha character.
        return NO;
    }
    // If the field is empty (the initial case) the number should be shifted to
    // start in the right most decimal place.
    short powerOf10 = 0;
    if ([textField.text isEqualToString:@""]) {
        powerOf10 = -_formatter.maximumFractionDigits;
    }
    // If the edit point is to the right of the decimal point we need to do
    // some shifting.
    else if (range.location + _formatter.maximumFractionDigits >= textField.text.length) {
        // If there's a range of text selected, it'll delete part of the number
        // so shift it back to the right.
        if (range.length) {
            powerOf10 = -range.length;
        }
        // Otherwise they're adding this many characters so shift left.
        else {
            powerOf10 = [string length];
        }
    }
    amount = [amount decimalNumberByMultiplyingByPowerOf10:powerOf10];
    
    // Replace the value and then cancel this change.
    textField.text = [_formatter stringFromNumber:amount];
    return NO;
}

- (IBAction)sendChallenge:(id)sender {
    //NSLog(@"Amount entered = %@\n", self.enterMoney.text);
    NSNumberFormatter *moneyFormat = [[NSNumberFormatter alloc] init];
    [moneyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *holder = [moneyFormat numberFromString:self.enterMoney.text];
    //NSString* avgamount = [self.enterMoney.text substringWithRange:[matches[1] range]];
    double holder1 = [holder doubleValue];
    NSLog(@"Amount entered = %f\n", holder1);
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
