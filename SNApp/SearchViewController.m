//
//  SearchViewController.m
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchView.h"
#import <CoreData/CoreData.h>
#import "SNAccountResourceManager.h"
#import "Account.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ProfileViewController.h"
#import "SearchTableViewCell.h"
#import "UIColor+SNColors.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UISearchBarDelegate>
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property(nonatomic,strong)UISearchBar* searchBar;
@property(nonatomic,strong)ProfileViewController* profileController;
@property(nonatomic,strong)UIRefreshControl* refreshControl;

@property(nonatomic,strong)NSString* previousSearchText;

@end

@implementation SearchViewController
#pragma mark - Life cycle
-(void)loadView {
    [super loadView];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    SearchView* searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.tableView = searchView.tableView;
    self.searchBar = searchView.searchBar;
    self.view =searchView;
}
static CGFloat const TOOLBAR_HEIGHT = 44.0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    [self.tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:@"Search Result Cell"];
    self.tableView.rowHeight = 66;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //Searchbar
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, 0, self.view.frame.size.width*0.3, TOOLBAR_HEIGHT)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.tintColor = [UIColor appMainColor];
    _searchBar.placeholder = NSLocalizedString(@"search.search-bar.placeholder.Search friends", nil);
    [_searchBar setImage:[UIImage imageNamed:@"atIcon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    //[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftViewMode:UITextFieldViewModeNever];
    
    //Back button
    //UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = nil;
    
    [_searchBar setImage:[UIImage new] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar.searchTextPositionAdjustment = UIOffsetMake(-19, 0);
    
    self.navigationItem.titleView =_searchBar;
    self.searchBar.delegate =self;
    [self.searchBar becomeFirstResponder];
    
    //Add refresh control
    UIRefreshControl *refresControl = [[UIRefreshControl alloc]init];
    refresControl.tintColor = [UIColor gray800Color];
    self.refreshControl =refresControl;
    
    //Initialize previousSearchText Property
    self.previousSearchText=@"";
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.searchBar resignFirstResponder];
    [[SNAccountResourceManager sharedManager] cancelSearch];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.tableView.backgroundView.alpha = 0;
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    searchText = [searchText lowercaseString];
    self.searchBar.text = searchText;
    if (searchText.length == 0 || [searchText isEqualToString:self.previousSearchText]) {
        return;
    }else {
        self.previousSearchText = searchText;
    }
    
    if (searchBar.text.length>2) {
        [self searchBarSearchButtonClicked:searchBar];
    }else{
        [[SNAccountResourceManager sharedManager] cancelSearch];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    }
    NSPredicate* predicate  = [NSPredicate predicateWithFormat:@"username BEGINSWITH[cd] %@",searchText];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString* searchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[SNAccountResourceManager sharedManager] cancelSearch];
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    }
    SearchViewController* __weak weakSelf = self;
    [[SNAccountResourceManager sharedManager] search:searchText success:^(NSArray *results) {
        [weakSelf.refreshControl endRefreshing];
        
        if (results.count == 0 && !self.refreshControl.isRefreshing ) {
            self.tableView.backgroundView.alpha = 1;
        }else{
            self.tableView.backgroundView.alpha = 0;
        }
        
    } failure:^(NSError *error) {
        [weakSelf.refreshControl endRefreshing];
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [[SNAccountResourceManager sharedManager] cancelSearch];
}

#pragma mark - Custom accessors
-(ProfileViewController *)profileController{
    if (!_profileController) {
        ProfileViewController* controller = [[ProfileViewController alloc] init];
        controller.managedObjectContext =self.managedObjectContext;
        controller.hidesBottomBarWhenPushed = YES;
        _profileController = controller;
    }
    return _profileController;
}
-(void)setRefreshControl:(UIRefreshControl *)refreshControl{
    _refreshControl = refreshControl;
    [self.tableView addSubview:_refreshControl];
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Account* account = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.profileController setAccount:account];
    [self.searchBar resignFirstResponder];
    [self.navigationController pushViewController:self.profileController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = [self.fetchedResultsController sections].count;
    if (count == 0) {
        count = 1;
    }
    return count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    if ([self.fetchedResultsController sections].count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Search Result Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Search Result Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Account* account = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
}

#pragma mark - Custom accessors

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController == nil) {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        fetchRequest.fetchBatchSize = 100;

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
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
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

-(NSString*)processText:(NSString*)textToProcess{
    textToProcess = [textToProcess stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.previousSearchText = textToProcess;
    
    if (textToProcess.length == 0 || [self.previousSearchText isEqualToString:textToProcess]) {
        self.previousSearchText = textToProcess;
        return nil;
    }else{
        return textToProcess;
    }
}

@end
