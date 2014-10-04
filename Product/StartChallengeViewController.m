//
//  StartChallengeViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "StartChallengeViewController.h"
#import "User.h"

@interface StartChallengeViewController () <UITextFieldDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

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
    
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.testMembers count]];
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /*  If the requesting table view is the search controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.searchResults count];
    } else {
        return [self.testMembers count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductCell";
    
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /*  If the requesting table view is the search controller's table view, configure the cell using the search results array, otherwise use the product array.
     */
    User *user;
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        user = [self.testMembers objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = user.githubUsername;
    return cell;
}



@end
