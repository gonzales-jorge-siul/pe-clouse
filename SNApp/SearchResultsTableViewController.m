//
//  SearchResultsTableViewController.m
//  SNApp
//
//  Created by Force Close on 10/5/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "ProfileViewController.h"
#import "SearchTableViewCell.h"
#import "Search.h"
#import "SNAccountResourceManager.h"
#import <CoreData/CoreData.h>
#import <AFNetworking/UIImageView+AFNetworking.h>


#import "SNObjectManager.h"

@interface SearchResultsTableViewController ()<NSFetchedResultsControllerDelegate>

@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property(nonatomic,strong)ProfileViewController* profileController;

@property(nonatomic,strong)NSString* searchText;

@property(nonatomic,strong)UIActivityIndicatorView* activityIndicator;

@end

@implementation SearchResultsTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 66;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:@"Search Result Cell"];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator setFrame:CGRectMake((self.view.bounds.size.width-self.activityIndicator.frame.size.width)/2.f, 20 , self.activityIndicator.bounds.size.width, self.activityIndicator.bounds.size.height)];
    [self.tableView.tableFooterView addSubview:activityIndicator];
    self.activityIndicator= activityIndicator;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Background table view
    UILabel* backgroundView = [[UILabel alloc] initWithFrame:CGRectMake(0, 6 , self.tableView.bounds.size.width, [UIFont systemFontOfSize:16].lineHeight)];
    backgroundView.numberOfLines = 1;
    backgroundView.text = NSLocalizedString(@"search.search-bar.Does not found match", nil);
    backgroundView.textAlignment = NSTextAlignmentCenter;
    backgroundView.textColor = [UIColor blackColor];
    backgroundView.font = [UIFont systemFontOfSize:16];
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    [view addSubview:backgroundView];
    view.alpha = 1.f;
    self.tableView.backgroundView = view;
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

#pragma mark - Public

-(void)getPersistentData:(NSString *)searchText{
    //Save searchText
    self.searchText = searchText;
    
    NSPredicate* predicate  = [NSPredicate predicateWithFormat:@"username BEGINSWITH[cd] %@",searchText];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
}

-(void)getData:(NSString *)searchText{
    SearchResultsTableViewController* __weak weakSelf = self;
    [self.activityIndicator startAnimating];
    self.tableView.backgroundView.alpha =0.f;
    [[SNAccountResourceManager sharedManager] cancelSearch];
    [[SNAccountResourceManager sharedManager] search:searchText success:^(NSArray *results) {
        [weakSelf.activityIndicator stopAnimating];
        if (results.count>0) {
            weakSelf.tableView.backgroundView.alpha = 0.f;
        }else{
            weakSelf.tableView.backgroundView.alpha = 1.f;
            NSLog(@"%@",self.tableView.backgroundView);
        }
    } failure:^(NSError *error) {
        [weakSelf.activityIndicator stopAnimating];
    }];
}

-(Account*)accountAtIndexPath:(NSIndexPath*)indexPath{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
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

-(ProfileViewController *)profileController{
    if (!_profileController) {
        ProfileViewController* controller = [[ProfileViewController alloc] init];
        controller.managedObjectContext =self.managedObjectContext;
        controller.hidesBottomBarWhenPushed = YES;
        _profileController = controller;
    }
    return _profileController;
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

-(void)savePersistentData{
    //Save persistent data
    NSManagedObjectContext* managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
}

@end
