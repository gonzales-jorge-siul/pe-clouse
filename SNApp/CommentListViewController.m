//
//  CommentListViewController.m
//  SNApp
//
//  Created by JG on 6/29/15.
//  Copyright (c) 2015 JG. All rights reserved.
//  :]

#import "CommentListViewController.h"
#import <CoreData/CoreData.h>
#import "SNCommentsResourceManager.h"
#import "SNPostResourceManager.h"
#import "CommentTableViewCell.h"
#import "Comment.h"
#import "CommentListView.h"
#import "SNConstans.h"
#import "ProfileViewController.h"
#import "UIColor+SNColors.h"
#import <LTNavigationBar/UINavigationBar+Awesome.h>
#import "SNObjectManager.h"
#import "SNLoginController.h"
#import "SNDate.h"

@interface CommentListViewController ()<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

// Core data
@property (strong,nonatomic)NSFetchedResultsController* fetchedResultsController;
@property (strong,nonatomic)Account* mainAccount;
@property (strong,nonatomic)NSMutableArray* arrayComments;
@property (getter=isDeleting)BOOL deleting;
@property (nonatomic,strong)NSDate* lastRequest;

//View
@property (weak, nonatomic)UITableView *tableView;
@property (weak, nonatomic)UITextField *comment;
@property (weak, nonatomic)UIButton *sendComment;
@property (strong,nonatomic)UIRefreshControl* refreshControl;
@property(nonatomic,weak)UIButton *surprisedButton;

@property BOOL shouldScrollToBotton;

@end

@implementation CommentListViewController

#pragma mark - Life cycle

-(void)loadView{
    [super loadView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CommentListView* commentListView =[[CommentListView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    //Table view reference
    self.tableView = commentListView.tableView;
    
    //Text field in toolbar
    self.comment =commentListView.commentText;
    
    //Button in toolbar
    self.sendComment = commentListView.sendButton;
    [self.sendComment addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    
    //Set view
    self.view = commentListView;
    
    //array
    self.arrayComments = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup table view
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    [self.tableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"Comment Cell"];
    //self.tableView.rowHeight =70.0;
    
    //Set draw in whole window
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //Add refresh control
    UIRefreshControl *refresControl = [[UIRefreshControl alloc]init];
    refresControl.tintColor = [UIColor gray800Color];
    [refresControl addTarget:self action:@selector(reloadComments:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl =refresControl;
    
    //Add an event when start editing to verify that user has been registered
    [self.comment addTarget:self action:@selector(verifyUserAccount:) forControlEvents:UIControlEventEditingDidBegin];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if (self.post) {
        //Add observer
//        [self.post addObserver:self forKeyPath:@"numComment" options:NSKeyValueObservingOptionNew context:nil];
//        [self.post addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
//        [self.post addObserver:self forKeyPath:@"like" options:NSKeyValueObservingOptionNew context:nil];
  //  }
    
   
    //Get back interaction to send comment button
    self.sendComment.userInteractionEnabled = YES;
    
    //Update navigation bar
    [self updateNavigationBarViewAtPosition:self.tableView.contentOffset.y];
    
    //Request comments
    [self loadComments];
    //[[self tableView] reloadData];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Make transparent navigation Bar
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setOpaque:NO];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [[self tableView] reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    //Save the new get comments (Search for a better performance)
    //[self.managedObjectContext save:nil];
    
    //Restore navigation bar to before state
    [self.navigationController.navigationBar setOpaque:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar lt_reset];
    
    //Cancel any request before left this view
    [[SNCommentsResourceManager sharedManager] cancelGetComments];
    
//    //Remove observer
//    [self.post removeObserver:self forKeyPath:@"numComment"];
//    [self.post removeObserver:self forKeyPath:@"rate"];
//    [self.post removeObserver:self forKeyPath:@"like"];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [self.comment resignFirstResponder];  // <---- Only edit this line
    
    [UIView commitAnimations];
    
    [super viewWillDisappear:animated];
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    if (!parent) {
        //Cancel any request before left this view
        [[SNCommentsResourceManager sharedManager] cancelGetComments];
        [[SNCommentsResourceManager sharedManager] cancelReloadComments];
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        
        [[SNCommentsResourceManager sharedManager] cancelComment];
        
        //Delete non-id comments
        self.deleting= YES;
        for (Comment* comment in self.arrayComments) {
            [self.managedObjectContext deleteObject:comment];
        }
        self.deleting= NO;

//      NSLog(@"COMMENT LIST VIEW CONTROLLER RETAIN COUNT: %d",[self reta])
//      [self saveData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"rate"]||[keyPath isEqualToString:@"numComment"]||[keyPath isEqualToString:@"like"]) {
//        self.post = self.post;
    }
}

#pragma mark - Custom Accesors

-(void)setPost:(Post *)post{
    _post = post;
    
    //Update view to current post
    CommentListView* view = (CommentListView*)self.view;
    view.post = self.post;
    
    //Surprised button
    self.surprisedButton = view.surprisedButton;
    
    if (self.surprisedButton.allTargets&&self.surprisedButton.allTargets.count<1) {
        [self.surprisedButton addTarget:self action:@selector(surprised:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    //Load its persistents comments if exist
    [self loadPersistentComments];
    
//    //Add observer
//    [self.post addObserver:self forKeyPath:@"numComment" options:NSKeyValueObservingOptionNew context:nil];
//    [self.post addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
//    [self.post addObserver:self forKeyPath:@"like" options:NSKeyValueObservingOptionNew context:nil];
}

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController == nil) {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        
//      [fetchRequest setIncludesPropertyValues:NO]; <-- this line cause unsorted results at moment of fetching
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
    return _fetchedResultsController;
}

-(void)setRefreshControl:(UIRefreshControl *)refreshControl{
    _refreshControl = refreshControl;
    [self.tableView addSubview:_refreshControl];
}


-(Account *)mainAccount{
    if (!_mainAccount) {
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@",[Account username]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (array != nil) {
            NSUInteger count = [array count]; // May be 0 if the object has been deleted.
            if(count == 1){
                _mainAccount = array[0];
            }
        }else{
            _mainAccount = nil;
        }
    }
    return _mainAccount;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Comment* comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Show selected profile
    ProfileViewController* controller = [[ProfileViewController alloc]init];
    
    //Get current user
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@",comment.account.username];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array != nil) {
        NSUInteger count = [array count]; // May be 0 if the object has been deleted.
        if(count == 1){
            controller.account = array[0];
        }
    }
    else {
        
    }
    
    controller.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:controller animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateNavigationBarViewAtPosition:self.tableView.contentOffset.y];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [self.fetchedResultsController sections].count;
    if (count == 0) {
        count = 1;
    }
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentsIcon"]];
    [image setFrame:CGRectMake(8, 8, 24, 24)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(36, 8, self.tableView.bounds.size.width - 36, 24)];
    label.text = [NSString stringWithFormat:NSLocalizedString(@"comment.section-header.%@ comments", @"{number of comments} comments"),self.post.numComment];
    
    [header addSubview:image];
    [header addSubview:label];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if ([self.fetchedResultsController sections].count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment* comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [CommentTableViewCell heightForText:comment.content frame:self.tableView.bounds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Comment Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Comment Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(CommentTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = (Comment *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.photoText = comment.account.photo;
    cell.nameText = [NSString stringWithFormat:@"@%@",comment.account.username];
    cell.commentText = comment.content;
    cell.date = comment.date;
}

#pragma  mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    if (self.shouldScrollToBotton) {
        [self scrollToBottom];
        self.shouldScrollToBotton = NO;
    }
//    [self.tableView reloadData];
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
            [self configureCell:(CommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Actions

- (IBAction)addComment:(id)sender {
    if (self.comment.text.length != 0) {
        
        if ([[SNLoginController sharedController] verifyIsGuest]) {
            [[SNLoginController sharedController] startLogin:SNLoginTypeExpandFunctions];
            if (self.comment.isFirstResponder) {
                [self.comment resignFirstResponder];
            }
            return;
        }
        
        Comment* newComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
        
//        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond
//        ;
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];
//        comps.hour += 4;
//        NSDate* date =[calendar dateFromComponents:comps];
        newComment.date =[SNDate serverDate];
        newComment.content =self.comment.text;
        
        //Change number of comments in post
        int value = [self.post.numComment intValue];
        self.post.numComment = [NSNumber numberWithInt:value+1];
        newComment.idPost = self.post.idPost;
    
        //Get current user
        [self.mainAccount addCommentsObject:newComment];
        
        //Add to array
        [self.arrayComments addObject:newComment];

        //Update UI
        [self.comment resignFirstResponder];
        
        CommentListViewController* __weak weakSelf = self;
        [[SNCommentsResourceManager sharedManager] commentWhitContent:newComment.content username:[Account username] idPost:self.post.idPost success:^(NSNumber *idComment) {
            
            if (weakSelf.arrayComments.count>0 && !weakSelf.isDeleting) {
                [(Comment*)[weakSelf.arrayComments firstObject] setIdComment:idComment];
                [weakSelf.arrayComments removeObjectAtIndex:0];
            }
            
        } failure:^(NSError *error) {
            [weakSelf cancelComment];
            [weakSelf showError:error];
        }];
        
        [[self.managedObjectContext registeredObjects] count];
        NSLog(@"MOC objects :%lu",(unsigned long)[[self.managedObjectContext registeredObjects] count]);
        
        self.comment.text =@"";
        self.shouldScrollToBotton = YES;
    }
}

-(IBAction)reloadComments:(id)sender{
    CommentListViewController* __weak weakSelf = self;
    [[SNCommentsResourceManager sharedManager] reloadComments:self.post.idPost date:self.lastRequest success:^(NSArray *data) {
        [weakSelf.refreshControl endRefreshing];
        for (Comment* comment in data) {
            comment.idPost = weakSelf.post.idPost;
        }
    } failure:^(NSError *error) {
        [weakSelf.refreshControl endRefreshing];
        [weakSelf showError:error];
    }];
    //Save date of last request
    self.lastRequest = [NSDate date];
}

-(IBAction)verifyUserAccount:(id)sender{
    BOOL isGuest = [[SNLoginController sharedController] verifyIsGuest];
    if (isGuest) {
        [[SNLoginController sharedController] startLogin:SNLoginTypeExpandFunctions];
        if (self.comment.isFirstResponder) {
            [self.comment resignFirstResponder];
        }
    }
}

-(IBAction)surprised:(id)sender{
    CommentListViewController* __weak weakSelf = self;
    Post *post = weakSelf.post;
    if (![post.like boolValue]) {
        post.rate = [NSNumber numberWithInt:[post.rate intValue]+1];
        post.like = @YES;
        [self doanimation];
        [self.surprisedButton setImage:[UIImage imageNamed:@"surprisedStatePressedIcon"] forState:UIControlStateNormal];
        [[SNPostResourceManager sharedManager] wowPostWithIDAccount:[Account accountId] idPost:post.idPost date:[NSDate date] success:^(ResponseServer* response){
            
        } failure:^(NSError *error) {
            [weakSelf cancelSurprised];
            post.rate = [NSNumber numberWithInt:[post.rate intValue]-1];
            post.like=@NO;
            [self.surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
        }];
    }
}
-(void)doanimation{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.tableView.tableHeaderView.bounds.size.height - [UIFont systemFontOfSize:40.f].lineHeight)/2.f, self.tableView.tableHeaderView.bounds.size.width, [UIFont systemFontOfSize:40.f].lineHeight)];
    label.font = [UIFont systemFontOfSize:40.f];
    label.text = NSLocalizedString(@"app.general.like", nil);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.f;
    
    UIView* view = [[UIView alloc] initWithFrame:self.tableView.tableHeaderView.bounds];
    view.backgroundColor = [UIColor appMainColor];
    view.alpha = 0.f;
    
    [view addSubview:label];
    [self.tableView.tableHeaderView addSubview:view];
    
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim1.fromValue = [NSNumber numberWithFloat:self.tableView.tableHeaderView.bounds.size.height];
    anim1.toValue = [NSNumber numberWithFloat:0.f];
    anim1.duration = 0.1;
    [view.layer addAnimation:anim1 forKey:@"cornerRadius"];
    
    [UIView animateWithDuration:0.1f animations:^{
        view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            label.alpha = 0.99f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.75f animations:^{
                label.alpha = 1.f;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
                [view removeFromSuperview];
            }];
        }];
    }];
}

#pragma mark - Helpers

-(void)loadPersistentComments{
    // Add the predicate for the current post
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idPost == %d",[self.post.idPost intValue]];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
   
    [self.fetchedResultsController.fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]]];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

-(void)loadComments{
    //Save date of last request
    self.lastRequest = [NSDate date];
    //Unable refresh data to this request finish
    self.refreshControl.userInteractionEnabled = NO;
    __weak typeof(self) weakself = self;
    [[SNCommentsResourceManager sharedManager] getCommentsWithPostId:self.post.idPost success:^(NSArray *data) {
            for (Comment* comment in data) {
                @autoreleasepool {
                    comment.idPost = weakself.post.idPost;
                }
            }
        weakself.refreshControl.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
       // [[SNCommentsResourceManager sharedManager] cancelGetComments];
        [weakself showError:error];
        weakself.refreshControl.userInteractionEnabled = YES;
    }];
}

-(void)cancelComment{
    [[SNCommentsResourceManager sharedManager] cancelComment];
}
-(void)cancelSurprised{
    [[SNPostResourceManager sharedManager] cancelWow];
}
-(void)showError:(NSError*)error{
    if ([error.domain isEqual:SNSERVICES_ERROR_DOMAIN]) {
        UIAlertController *alert;
        UIAlertAction *alertActionOK;
        switch (error.code) {
            case SNNoServer:
                alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-server-connection", nil)  message:NSLocalizedString(@"comment.alert.no server message", nil) preferredStyle:UIAlertControllerStyleAlert];
                alertActionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:alertActionOK];
                [self presentViewController:alert animated:YES completion:nil];
                break;
            case SNNoInternet:
                alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"app.error.no-internet-connection", nil) message:NSLocalizedString(@"comment.alert.no internet message", nil)preferredStyle:UIAlertControllerStyleAlert];
                alertActionOK = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:alertActionOK];
                [self presentViewController:alert animated:YES completion:nil];
                break;
        }
    }
}

-(void)scrollToBottom{
    NSInteger rows=(float)[self tableView:self.tableView numberOfRowsInSection:0];;
    if (rows>0) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rows-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)updateNavigationBarViewAtPosition:(CGFloat)position{
    CGFloat alpha    = position/(self.view.bounds.size.width-64);
    
    UIColor* color = [UIColor appMainColor];
    if (alpha<=1) {
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
        self.navigationItem.title = @"";
    }else{
        //self.navigationItem.title = self.post.content;
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:1]];
    }
}

-(void)saveData{
    NSError* error;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext saveToPersistentStore:&error]) {
        //handle error
        //abort();
    }
}

@end
