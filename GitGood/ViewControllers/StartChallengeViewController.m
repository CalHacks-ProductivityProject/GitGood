//
//  StartChallengeViewController.m
//  Product
//
//  Created by Stephen Meriwether on 10/4/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "StartChallengeViewController.h"
#import "GenericGitGoodUser.h"
#import "LocalGitGoodUser.h"
#import <Parse/Parse.h>

@interface StartChallengeViewController () <UITextFieldDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

// For use in Storyboards
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *numberOfWeeks;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *startMatchButton;
@property (strong, nonatomic) IBOutlet UITextField *enterMoney;

// Session management.
@property (nonatomic) dispatch_queue_t dumpQueue;
@property (nonatomic) dispatch_queue_t searchQueue;

// Data Models / Utilities
@property (nonatomic) NSMutableArray *userAccounts;
@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results
@property (nonatomic, strong) NSMutableArray *challangeAdditions; // Filtered search results
@property (nonatomic, readonly) int moveDistance;
@property (nonatomic, readonly) float defaultPosition;
@property (nonatomic, readonly) float movedPosition;

// UI
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultsController;
@property (strong, nonatomic) NSNumberFormatter *formatter;

// Alerts
@property (nonatomic) UIAlertView *alert;

@end

@implementation StartChallengeViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [self userNameDump];
    
    [self setupNavBar];
    [self setupSearchController];
    [self setupModel];
    [self setupUI];
    
    [self setMoveDistance:160];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _numberOfWeeks.delegate = self;
    _enterMoney.delegate = self;
    
    _searchResultsController.tableView.dataSource = self;
    _searchResultsController.tableView.delegate = self;
    
    _searchController.searchResultsUpdater = self;

    self.definesPresentationContext = YES;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setMoveDistance:(int)moveDistance
{
    _moveDistance = moveDistance;
}

- (void)setDefaultPosition:(float)defaultPosition
{
    _defaultPosition = defaultPosition;
}

- (void)setMovedPosition:(float)movedPosition
{
    _movedPosition = movedPosition;
}

- (void)setupUI
{
    _tableView.allowsSelection = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    _formatter = [NSNumberFormatter new];
    [_formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [_formatter setLenient:YES];
    [_formatter setGeneratesDecimalNumbers:YES];
    
    CGRect frame = self.view.frame;
    [self setDefaultPosition:frame.origin.y];
    [self setMovedPosition:frame.origin.y - self.moveDistance];
}

- (void)setupModel
{
    _searchResults = [[NSMutableArray alloc] init];
    _userAccounts = [[NSMutableArray alloc] init];
    _challangeAdditions = [[NSMutableArray alloc] init];
    _searchResults = [NSMutableArray arrayWithCapacity:[self.userAccounts count]];
}

- (void)setupNavBar
{
    // The navigation bar through out the application has needed a white (color) title.
    // This screen will use the default background so the black (color) is needed.
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],
                                               NSForegroundColorAttributeName,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
}

- (void)setupSearchController
{
    _searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    _searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    _tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action Methods

- (IBAction)timeEditing:(id)sender {
    self.numberOfWeeks.delegate = nil;
}

- (IBAction)timeEditingEnd:(id)sender {
    self.numberOfWeeks.delegate = self;
}


- (IBAction)cancelNewChallenege:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editTable:(UIBarButtonItem*)sender
{
    NSLog(@"%@", sender.title);
    if ([sender.title isEqualToString:@"Edit"]) {
        [self.tableView setEditing: YES animated: YES];
        [sender setTitle:@"Done"];
    }
    else {
        [self.tableView setEditing: NO animated: YES];
        [sender setTitle:@"Edit"];
    }
}

- (IBAction)sendChallenge:(id)sender {
    
    if ([self.challangeAdditions count] == 0 && [self.numberOfWeeks.text isEqualToString:@""] && [self.enterMoney.text isEqualToString:@""]) {
        [self showRequirementsAlert];
        return;
    }
    
    //NSLog(@"Amount entered = %@\n", self.enterMoney.text);
    NSNumberFormatter *moneyFormat = [[NSNumberFormatter alloc] init];
    NSNumberFormatter *numberFormat = [[NSNumberFormatter alloc] init];
    [numberFormat setNumberStyle:NSNumberFormatterNoStyle];
    [moneyFormat setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *holder = [moneyFormat numberFromString:self.enterMoney.text];
    NSNumber *duration = [numberFormat numberFromString:self.numberOfWeeks.text];
    //NSString* avgamount = [self.enterMoney.text substringWithRange:[matches[1] range]];
    //double moneyPerPerson = [holder doubleValue];
    
    PFObject *game = [PFObject objectWithClassName:@"Game"];
    
    
    for (int i = 0; i < [self.challangeAdditions count]; i++) {
        GenericGitGoodUser *user = [self.challangeAdditions objectAtIndex:i];
        
        if (user) {
            [game addObject:[user username] forKey:@"PendingPlayers"];
        }
    }
    
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:@"smeriwether"];
    [push setMessage:@"You were invited to join a GitGood Challange!"];
    [push sendPushInBackground];
    
    // add the current user to the game
    [game addObject:[[LocalGitGoodUser sharedInstance] username] forKey:@"ApprovedPlayers"];
    
    game[@"Time"] = duration;
    game[@"Admin"] = [[LocalGitGoodUser sharedInstance] username];
    game[@"moneyPerPlayer"] = holder;
    [game saveInBackground];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard Methods

- (void) dismissKeyboard
{
    [self.enterMoney resignFirstResponder];
    [self.numberOfWeeks resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    // the keyboard is hiding reset the table's height
    NSTimeInterval animationDuration =
    [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.view.frame;
    frame.origin.y = _defaultPosition;
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
    frame.origin.y = _movedPosition;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
}


#pragma mark - TextField Delegate Methods

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    return YES;
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
    GenericGitGoodUser *user;
    
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        user = [self.challangeAdditions objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [user username];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.challangeAdditions addObject:[self.searchResults objectAtIndex:indexPath.row]];
    [self.tableView reloadData];
    [self.searchController setActive:NO];
    [self.startMatchButton setEnabled:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.challangeAdditions removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //add code here for when you hit delete
    }
}


#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSString *searchString = [self.searchController.searchBar text];
    [self updateFilteredContentForProductName:searchString];
    
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];

}

- (void)userNameDump
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"userInfo"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                GenericGitGoodUser *user = [[GenericGitGoodUser alloc] init];
                [user setUsername:[object objectForKey:@"username"]];
                [self.userAccounts addObject:user];
            }
        }
    }];
    
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForProductName:(NSString *)userName{
    
    // Update the filtered array based on the search text and scope.
    if ((userName == nil) || [userName length] == 0) {
        // If there is no search string and the scope is "All".
        [self.searchResults addObjectsFromArray:self.userAccounts];
        return;
    }
    
    if ([self.searchResults count]) {
        [self.searchResults removeAllObjects]; // First clear the filtered array.
    }
    
    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (GenericGitGoodUser *user in self.userAccounts) {
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange userNameRange = NSMakeRange(0, [user username].length);
        NSRange foundRange = [[user username] rangeOfString:userName options:searchOptions range:userNameRange];
        if (foundRange.length > 0) {
            [self.searchResults addObject:user];
        }
    }
}

- (void)showRequirementsAlert
{
    self.alert =[[UIAlertView alloc ] initWithTitle:@"Requirements Not Fulfilled"
                                                     message:@"Requirements: 1 Other User, Amount per Week, Length of Time"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"Okay", nil];
    [self.alert show];
}



@end
