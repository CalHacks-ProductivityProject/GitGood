//
//  StartChallengeViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "StartChallengeViewController.h"
#import "User.h"
#import <Parse/Parse.h>

@interface StartChallengeViewController () <UITextFieldDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results
@property (nonatomic, strong) NSMutableArray *challangeAdditions; // Filtered search results
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
// !!!  REMOVE LATER  !!!
@property (nonatomic) NSMutableArray *testMembers;

@end

@implementation StartChallengeViewController

- (void)viewDidLoad {
    
    
    self.searchResults = [[NSMutableArray alloc] init];
    self.testMembers = [[NSMutableArray alloc] init];
    self.challangeAdditions = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    for (int i = 0; i < 10; i++) {
        User *user = [[User alloc] init];
        user.githubUsername = [NSString stringWithFormat:@"%d %@", i, @"user"];
        [self.testMembers addObject:user];
    }
    
    
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
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@\n", user);
    
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
    self.tableView.allowsSelection = YES;
    
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
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    //NSLog(@"Amount entered = %@\n", self.enterMoney.text);
    NSNumberFormatter *moneyFormat = [[NSNumberFormatter alloc] init];
    [moneyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *holder = [moneyFormat numberFromString:self.enterMoney.text];
    //NSString* avgamount = [self.enterMoney.text substringWithRange:[matches[1] range]];
    double moneyPerPerson = [holder doubleValue];
    
    PFObject *game = [PFObject objectWithClassName:@"Game"];
    [game addObject:@"trineroks" forKey:@"PendingPlayers"];
    [game addObject:username forKey:@"AcceptedPlayers"];
    game[@"moneyPerPlayer"] = holder;
    
    [game saveInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"userInfo"];
    [query whereKeyExists:@"username"];
    [query whereKey:@"username" equalTo:@"trineroks"];
    
    NSArray *results = [query findObjects];
    
    if ([results count] != 0)
    {
        NSLog(@"Username found!");
    }
    
    NSLog(@"Amount entered = %f\n", moneyPerPerson);
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /*  If the requesting table view is the search controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.searchResults count];
    } else {
        return [self.challangeAdditions count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    /*  If the requesting table view is the search controller's table view, configure the cell using the search results array, otherwise use the product array.
     */
    User *user;
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        user = [self.challangeAdditions objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = user.githubUsername;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.challangeAdditions addObject:[self.searchResults objectAtIndex:indexPath.row]];
    [self.tableView reloadData];
    [self.searchController setActive:NO];
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    [self updateFilteredContentForProductName:searchString];
    
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForProductName:(NSString *)userName{
    
    // Update the filtered array based on the search text and scope.
    if ((userName == nil) || [userName length] == 0) {
        // If there is no search string and the scope is "All".
        [self.searchResults addObjectsFromArray:self.testMembers];
        return;
    }
    
    if ([self.searchResults count]) {
        [self.searchResults removeAllObjects]; // First clear the filtered array.
    }
    
    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (User *user in self.testMembers) {
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange userNameRange = NSMakeRange(0, user.githubUsername.length);
        NSRange foundRange = [user.githubUsername rangeOfString:userName options:searchOptions range:userNameRange];
        if (foundRange.length > 0) {
            [self.searchResults addObject:user];
        }
    }
}



@end
