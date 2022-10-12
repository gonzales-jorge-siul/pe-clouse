//
//  SearchTableViewController.m
//  SNApp
//
//  Created by Jorge Gonzales on 10/5/15.
//  Copyright © 2015 Jorge Gonzales. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SearchResultsTableViewController.h"
#import "ProfileViewController.h"
#import "SearchTableViewCell.h"
#import "SNAccountResourceManager.h"
#import "UIColor+SNColors.h"
#import "Search.h"

@interface SearchTableViewController ()<UISearchBarDelegate, UISearchControllerDelegate,UISearchResultsUpdating,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;

// secondary search results table view
@property (nonatomic, strong) SearchResultsTableViewController *resultsTableController;

//Fetched results controller
@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;

@property(nonatomic,strong)ProfileViewController* profileController;

@end

@implementation SearchTableViewController

NSUInteger const NUMBER_OF_SEARCHES_TO_DISPLAY = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _resultsTableController = [[SearchResultsTableViewController alloc] init];
    _resultsTableController.managedObjectContext = self.managedObjectContext;
    _resultsTableController.tableView.delegate = self;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;

    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.providesPresentationContextTransitionStyle = YES;

    self.navigationController.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.extendedLayoutIncludesOpaqueBars = NO;
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationController.providesPresentationContextTransitionStyle = YES;

    //Search bar
    self.searchController.searchBar.barTintColor = [UIColor appMainColor];
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.searchController.searchBar.translucent = NO;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"search.search-bar.placeholder.Search friends", nil);
    self.searchController.searchBar.showsCancelButton = YES;
    [self.searchController.searchBar setImage:[[UIImage imageNamed:@"atIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchController.searchBar setTintColor:[UIColor grayColor]];
    
    self.tableView.rowHeight = 66;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:@"Search Result Cell"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self deleteSearches:NUMBER_OF_SEARCHES_TO_DISPLAY];
    
    //Load data
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.navigationItem.hidesBackButton) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.searchController.isActive) {
        [self.searchController setActive:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [self.fetchedResultsController sections].count;
    if (count == 0) {
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if ([self.fetchedResultsController sections].count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Search Result Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Search Result Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString* searchText = [(Search*)[self.fetchedResultsController objectAtIndexPath:indexPath] searchText];
    
    Account* account = [self accountForUsername:searchText];
    
    if (account) {
        cell.textLabel.text = [NSString stringWithFormat:@"@%@",account.username];
        cell.detailTextLabel.text = account.status;
        
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        cell.imageView.layer.cornerRadius = 4.f;
        cell.imageView.clipsToBounds = YES;
        
        cell.separatorInset = UIEdgeInsetsMake(0,0, 0, 56);
        
        if (![account.photo isEqualToString:@""]) {
            [cell.imageView setImageWithURL:[NSURL URLWithString:account.photo] placeholderImage:[UIImage imageNamed:@"whiteImage"]];
        }else{
            [cell.imageView setImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
        }
    }else{
        cell.textLabel.text = searchText;
    }
}

-(Account*)accountForUsername:(NSString*)username{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username LIKE[cd] %@", username];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array && array.count == 1) {
        return [array firstObject];
    }
    return nil;
}

#pragma mark - Table view delegate

CGFloat const HEIGHT_HEADER_VIEW = 35.f;

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView!=self.tableView) {
        return nil;
    }
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, HEIGHT_HEADER_VIEW)];
    view.backgroundColor = [UIColor gray200Color];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, view.bounds.size.width, HEIGHT_HEADER_VIEW)];
    label.numberOfLines = 1;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor gray800Color];
    label.text = NSLocalizedString(@"search.section-header.Recent searches", nil);
    
    UIButton* clearSearchesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString* buttonText =  NSLocalizedString(@"search.section-header.Clear searches", nil);
    CGSize textSize = [buttonText boundingRectWithSize:CGSizeMake(view.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.f]} context:nil].size;
    
    [clearSearchesButton setFrame:CGRectMake( view.bounds.size.width - textSize.width - 8 , 0, textSize.width +4  , HEIGHT_HEADER_VIEW)];
    [clearSearchesButton setTitle:buttonText forState:UIControlStateNormal];
    [clearSearchesButton setTitleColor:[UIColor gray800Color] forState:UIControlStateNormal];
    [clearSearchesButton setContentMode:UIViewContentModeRight];
    [clearSearchesButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    
    [clearSearchesButton addTarget:self action:@selector(deleteAllSearches:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:label];
    [view addSubview:clearSearchesButton];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView!=self.tableView) {
        return 0;
    }
    return HEIGHT_HEADER_VIEW;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Account* account;
    if (tableView == self.tableView) {
        NSString* searchText = [(Search*)[self.fetchedResultsController objectAtIndexPath:indexPath] searchText];
        account = [self accountForUsername:searchText];
        self.searchController.searchBar.text = searchText;
    }else{
        account = [self.resultsTableController accountAtIndexPath:indexPath];
    }
    if (account) {
        [self.profileController setAccount:account];
        [self.navigationController pushViewController:self.profileController animated:YES];
        
        Search* search =[self existSearchText:account.username];
        if (!search) {
            search = [NSEntityDescription insertNewObjectForEntityForName:@"Search" inManagedObjectContext:self.managedObjectContext];
            //    search.searchText = self.searchText;
            search.searchText = account.username;
            search.date = [NSDate date];
        }else{
            search.date = [NSDate date];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(ProfileViewController *)profileController{
    if (!_profileController) {
        ProfileViewController* controller = [[ProfileViewController alloc] init];
        controller.managedObjectContext =self.managedObjectContext;
        controller.hidesBottomBarWhenPushed = YES;
        _profileController = controller;
    }
    return _profileController;
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchBar.text = searchText.lowercaseString;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
//    Search* search = [NSEntityDescription insertNewObjectForEntityForName:@"Search" inManagedObjectContext:self.managedObjectContext];
//    search.searchText = searchBar.text;
//    search.date = [NSDate date];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
//    [self.resultsTableController.tableView addSubview:self.searchController.searchBar];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
    [self showKeyboard];
}

-(void)showKeyboard{
    SearchTableViewController* __weak weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.000001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.searchController.searchBar becomeFirstResponder];
    });
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString* searchText = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    SearchResultsTableViewController *tableController = (SearchResultsTableViewController *)self.searchController.searchResultsController;
    [tableController getData:searchText];
    [tableController getPersistentData:searchText];
    [tableController.tableView reloadData];
}

#pragma mark - Custom accessors

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController == nil) {
        
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Search" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        fetchRequest.fetchLimit = NUMBER_OF_SEARCHES_TO_DISPLAY;
//        fetchRequest.fetchBatchSize = NUMBER_OF_SEARCHES_TO_DISPLAY;
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
    return _fetchedResultsController;
}

#pragma mark - Fetched results controller

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(UITableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Helpers

-(IBAction)deleteAllSearches:(id)sender{
    [self deleteSearches:0];
}

-(void)deleteSearches:(NSUInteger)number{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Search" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        return;
    }
    if (fetchedObjects.count>number) {
        NSUInteger numberOfObjectsToDelete = fetchedObjects.count - number;
        for (int i = 0; i<numberOfObjectsToDelete; i++) {
            [self.managedObjectContext deleteObject:fetchedObjects[i]];
        }
    }
}

-(Search*)existSearchText:(NSString*)searchText{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Search"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    [request setIncludesPropertyValues:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchText LIKE[cd] %@", searchText];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array && array.count == 1) {
        return [array firstObject];
    }
    return nil;
}

@end