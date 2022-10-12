//
//  PostListViewController.m
//  SNApp
//
//  Created by Force Close on 7/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostListViewController.h"
#import "PostListView.h"
#import "PostStyleTextTableViewCell.h"
#import "PostStylePhotoTableViewCell.h"
#import "PostStylePhotoAndTextTableViewCell.h"
#import "PostStyleEmptyTableViewCell.h"
#import "ViewMoreFooter.h"

#import "SNPostResourceManager.h"

#import "SNLocationManager.h"
#import "Preferences.h"
#import "SNConstans.h"
#import "UIColor+SNColors.h"

#import "AddPostViewController.h"
#import "CommentListViewController.h"
#import "SearchTableViewController.h"
#import "SNLoginController.h"

#import "ReportTableViewController.h"

@interface PostListViewController ()<UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,AddPostProtocol,SNLocationManagerDelegate,ReportProtocol>

//View properties
@property(nonatomic,weak)UITableView* tableView;
@property(nonatomic,weak)SNLocationManager* locationManager;
@property(nonatomic,strong)UIRefreshControl* refreshControl;

//Comment controller
@property(nonatomic,strong)CommentListViewController* commentController;

//Internal properties
@property(nonatomic,strong)NSIndexPath* panIndexPath;
@property(nonatomic,strong)UIAlertController* alertController;
@property(nonatomic)SNPostDirection directionToDelete;

@end

@implementation PostListViewController

NSString* const SN_POST_STYLE_TEXT_CELL =@"Post Style Text Cell";
NSString* const SN_POST_STYLE_PHOTO_CELL =@"Post Style Photo Cell";
NSString* const SN_POST_STYLE_PHOTO_TEXT_CELL =@"Post Style Photo And Text Cell";
NSString* const SN_POST_STYLE_EMPTY_CELL =@"Post Style Empty Cell";

#pragma mark - Life cycle

-(void)loadView{
    [super loadView];
    //Get size of screen
    CGSize mainRect = [UIScreen mainScreen].bounds.size;
    
    //Create custom view
    PostListView* postView = [[PostListView alloc] initWithFrame:CGRectMake(0, 0, mainRect.width, mainRect.height)];
    
    //Assign tableView to this controller
    self.tableView = postView.tableView;
    
    //Add target to news button
    [postView.newsButton addTarget:self action:@selector(scrollToTop:) forControlEvents:UIControlEventTouchUpInside];
    
    //Add target to add post button
    [postView.buttonBackground addTarget:self action:@selector(addPost:) forControlEvents:UIControlEventTouchUpInside];
    
    //Add target to see more button
    [postView.footerView.seeMoreButton addTarget:self action:@selector(loadMorePost:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = postView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TableView delegate and dataSource
    self.tableView.delegate =self;
    [self.dataSource setTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    //Table view custom cells
    [self.tableView registerClass:[PostStyleTextTableViewCell class] forCellReuseIdentifier:SN_POST_STYLE_TEXT_CELL];
    [self.tableView registerClass:[PostStylePhotoTableViewCell class] forCellReuseIdentifier:SN_POST_STYLE_PHOTO_CELL];
    [self.tableView registerClass:[PostStylePhotoAndTextTableViewCell class] forCellReuseIdentifier:SN_POST_STYLE_PHOTO_TEXT_CELL];
    [self.tableView registerClass:[PostStyleEmptyTableViewCell class] forCellReuseIdentifier:SN_POST_STYLE_EMPTY_CELL];
    
    [self setupView];
    
    //Location manager
    [self.locationManager addLocationManagerDelegate:self];
    
    //Observing
    [(NSObject*)self.dataSource addObserver:self forKeyPath:@"thereIsNewPost" options:NSKeyValueObservingOptionNew context:nil];
    [(NSObject*)self.dataSource addObserver:self forKeyPath:@"shouldShowBackground" options:NSKeyValueObservingOptionNew context:nil];
    
    //Load persistent post at last location
    [self loadPersistentPostsWhitLocation:self.locationManager.lastLocation];

    //Pan recognizer to delete action
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.maximumNumberOfTouches=1;
    panRecognizer.minimumNumberOfTouches =1;
    panRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:panRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"%@:%@",@"POST MEMORY WARNING",self.title);
    
    //Should delete comment controller;
    self.commentController = nil;
    
    //Core data refresh
    NSError* error;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@":%@",error);
    }
    [self.dataSource becomeFaultingPosts];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Colour navigation bar at any time it will visible
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor appMainColor];
    self.navigationController.navigationBar.opaque =YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidDisappear:(BOOL)animated{
    //Cancel refreshing
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [super viewDidDisappear:animated];
}

-(void)dealloc{
    [(NSObject*)self.dataSource removeObserver:self forKeyPath:@"thereIsNewPost"];
    [(NSObject*)self.dataSource removeObserver:self forKeyPath:@"shouldShowBackground"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"thereIsNewPost"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
            [(PostListView*)self.view showNewsButton];
            [self.dataSource setThereIsNewPost:@NO];
        }
    }
    if ([keyPath isEqualToString:@"shouldShowBackground"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
            [self.tableView.backgroundView setAlpha:1.f];
            if (self.tableView.tableFooterView) {
                self.tableView.tableFooterView = nil;
            }
        }else{
            [self.tableView.backgroundView setAlpha:0.f];
            if (!self.tableView.tableFooterView) {
                self.tableView.tableFooterView = [(PostListView*)self.view footerView];
            }
        }
    }
}

#pragma mark - Custom accessors

-(void)setDataSource:(id<UITableViewDataSource,PostDataSourceProtocol>)dataSource{
    _dataSource =dataSource;
    //Set title and navigation item title
    self.title = [_dataSource name];
    self.navigationItem.title = [_dataSource navigationBarName];
    //Set tab bar image.
    self.tabBarItem.image = [_dataSource tabBarImage];
}

-(SNLocationManager *)locationManager{
    if (!_locationManager) {
        SNLocationManager* manager = [SNLocationManager sharedInstance];
        _locationManager =manager;
    }
    return _locationManager;
}

-(void)setRefreshControl:(UIRefreshControl *)refreshControl{
    _refreshControl = refreshControl;
    [self.tableView addSubview:_refreshControl];
    [self.tableView sendSubviewToBack:_refreshControl];
}

-(CommentListViewController *)commentController{
    if (!_commentController) {
        CommentListViewController* controller = [[CommentListViewController alloc] init];
        controller.managedObjectContext =self.managedObjectContext;
        controller.hidesBottomBarWhenPushed = YES;
        controller.automaticallyAdjustsScrollViewInsets = NO;
        _commentController =controller;
    }
    return _commentController;
}

#pragma mark - Actions

-(void)addPost:(id)sender{
    if ( [[SNLoginController sharedController] verifyIsGuest] || [[SNLoginController sharedController] verifyIsLogin]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"addPostNavigationController"];
        AddPostViewController* addPost = (AddPostViewController*)[controller topViewController];
        addPost.delegate =self;
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        PostListViewController* __weak weakSelf = self;
        [[SNLoginController sharedController] registerAsGuest:^(BOOL success, NSError *error) {
            if (success) {
                [weakSelf openAddPost];
            }
        }];
    }
}

-(void)search:(id)sender{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchTableViewController* controller=(SearchTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SearchController"];
//    SearchTableViewController* controller = [[SearchTableViewController alloc] init];
    controller.managedObjectContext =self.managedObjectContext;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)scrollToTop:(id)sender{
    [(PostListView*)self.view dismissNewsButton];
    [self.dataSource setThereIsNewPost:@NO];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(IBAction)loadPosts{
  //[[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
    Post* firstPost = [[self dataSource] postForIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
    [self loadPostsWithLocation:self.locationManager.lastLocation shouldGetOlders:NO requestDate:firstPost?firstPost.date:[NSDate dateWithTimeIntervalSinceNow:-86400]];
}

-(IBAction)loadMorePost:(id)sender{
    
    NSInteger numberOfPost =[self.dataSource numberOfPost];
    Post* lastPost = [[self dataSource] postForIndexPath: [NSIndexPath indexPathForRow:numberOfPost-1 inSection:0]];
    NSLog(@"%@",lastPost.date);
    [self loadPostsWithLocation:self.locationManager.lastLocation shouldGetOlders:YES requestDate:lastPost?lastPost.date:[NSDate dateWithTimeIntervalSinceNow:-86400]];
//    [self loadPostsWithLocation:self.locationManager.lastLocation shouldGetOlders:YES requestDate:[NSDate dateWithTimeIntervalSinceNow:-14400]];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Post* post=[self.dataSource postForIndexPath:indexPath];
    if (!post) {
        return;
    }
//    [self pushCommentControllerWithPost:post];
    self.commentController.post = post;
    [self.navigationController pushViewController:self.commentController animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self dismisNewsButton];
    [self.dataSource setThereIsNewPost:@NO];
}

#pragma mark - Location manager delegate

-(void)locationManagerDidUpdateLocation:(CLLocation *)location{

    //Show loading post animation
    [(PostListView*)self.view showNewLocationImage];
    
    //When new location arrived, get post of the last 24 hours
    [self loadPostsWithLocation:location shouldGetOlders:NO requestDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
    
    //Initial state
    [(ViewMoreFooter*)self.tableView.tableFooterView initialState];
    
    //Print new location
    NSLog(@"Location : %@",location);
}

-(void)didDeniedAuthorizationStatus:(CLAuthorizationStatus)status{
    [self openUserSetting];
}

#pragma mark - Add post delegate
-(void)didDone:(BOOL)done{
    if (done) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Pan Gesture

- (void)handlePan:(UIPanGestureRecognizer *)panRecognizer {
    CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint panLocation = [panRecognizer locationInView:self.tableView];
        self.panIndexPath= [self.tableView indexPathForRowAtPoint:panLocation];
        PostBaseTableViewCell* cell = (PostBaseTableViewCell*)[self.tableView cellForRowAtIndexPath:self.panIndexPath];
        CGPoint center = cell.center;
        center.x = self.view.bounds.size.width/2.0f;
        cell.center = center;
        [self moveCellRowAtIndexPath:self.panIndexPath xDistance:translation.x];
    }else{
        if (panRecognizer.state == UIGestureRecognizerStateChanged) {
            [self moveCellRowAtIndexPath:self.panIndexPath xDistance:translation.x];
        }else if ((panRecognizer.state == UIGestureRecognizerStateCancelled) || (panRecognizer.state == UIGestureRecognizerStateEnded)){
            if (!self.panIndexPath) {
                return;
            }
            if (fabs(translation.x)<(0.3333)*self.tableView.bounds.size.width) {
                [self moveCellRowAtIndexPath:self.panIndexPath xDistance:0];
                self.panIndexPath = nil;
            }else{
                if (translation.x>0) {
                    self.directionToDelete = SNPostRight;
                }else{
                    self.directionToDelete = SNPostLeft;
                }
                
                [self showOptionsToRowAtIndexPath:self.panIndexPath ];
            }
        }
    }
}

-(void)showOptionsToRowAtIndexPath:(NSIndexPath*)indexpath{

    [self presentViewController:self.alertController animated:YES completion:nil];
}

-(UIAlertController *)alertController{
    if (!_alertController) {
        UIAlertController* alertController = [[UIAlertController alloc] init];
        alertController.title = NSLocalizedString(@"app.general.delete", nil);
        alertController.message = NSLocalizedString(@"post.delete-action.alert-message", nil);
        
        PostListViewController* __weak weakSelf = self;
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [weakSelf moveCellRowAtIndexPath:weakSelf.panIndexPath xDistance:0];
        }];
        UIAlertAction* reportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.report", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf openOptionReportToIdPost:[weakSelf.dataSource postForIndexPath:weakSelf.panIndexPath].idPost];
        }];
        UIAlertAction* deleteAction =[UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [weakSelf.dataSource deletePostAtIndexPath:weakSelf.panIndexPath direction:[self directionToDelete]];
            weakSelf.panIndexPath = nil;
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:reportAction];
        [alertController addAction:deleteAction];
        _alertController = alertController;
    }
    return _alertController;
}

-(void)openOptionReportToIdPost:(NSNumber*)idPost{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* navController = [storyboard instantiateViewControllerWithIdentifier:@"Report Navigation Controller"];
    ReportTableViewController* reportController = (ReportTableViewController*)[navController topViewController];
    reportController.idPost = idPost;
    reportController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}


-(void)moveCellRowAtIndexPath:(NSIndexPath*)indexPath xDistance:(CGFloat)x{
    UITableViewCell* cell=[self.tableView cellForRowAtIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeTranslation(x, 0);
}

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panRecognizer{
    CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
    
    // Check for horizontal gesture
    if (fabs(translation.x) > fabs(translation.y))
    {
        return YES;
    }
    
    return NO;
}
#pragma mark - Report protocol
-(void)reportController:(ReportTableViewController *)controller done:(BOOL)done{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (done) {
        [self.dataSource deletePostAtIndexPath:self.panIndexPath direction:SNPostLeft];
        self.panIndexPath = nil;
    }else{
        [self moveCellRowAtIndexPath:self.panIndexPath xDistance:0];
        self.panIndexPath = nil;
    }
}

#pragma mark - Helpers

-(void)setupView{
    //Set equal height for all rows
    self.tableView.rowHeight = self.view.bounds.size.width;
    self.tableView.backgroundColor = [UIColor gray200Color];
    self.tableView.opaque = YES;

    //Add refresh control
    UIRefreshControl *refresControl = [[UIRefreshControl alloc]init];
    refresControl.tintColor = [UIColor gray800Color];
    [refresControl addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];
    self.refreshControl =refresControl;
    
    //Add bar button item left
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addPostIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(addPost:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //Add bar button item right
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //Back button without title
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    //Set tab bar color
    self.tabBarController.tabBar.barTintColor=[UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.tabBar.opaque =YES;
    self.tabBarController.tabBar.tintColor =[UIColor appMainColor];
    
    //Set navigation bar color and bar state
    self.navigationController.navigationBar.barTintColor = [UIColor appMainColor];
    self.navigationController.navigationBar.opaque =YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)openUserSetting{
    UIAlertController* alertController = [[UIAlertController alloc] init];
    alertController.title = NSLocalizedString(@"post.location-service.alert-title", nil);
    alertController.message = NSLocalizedString(@"post.location-service.alert-message", nil);
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction* openAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"post.location-service.alert-open settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertController addAction:openAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showError:(NSError*)error{
    if ([error.domain isEqual:SNSERVICES_ERROR_DOMAIN]) {
        switch (error.code) {
            case SNNoServer:
                [(PostListView*)self.view showMessageAtTop:NSLocalizedString(@"post.upper-message.no sever", nil)];
                break;
            case SNNoInternet:
                [(PostListView*)self.view showMessageAtTop:NSLocalizedString(@"post.upper-message.no internet", nil)];
                break;
        }
    }
}

-(void)dismisNewsButton{
    [(PostListView*)self.view dismissNewsButton];
}

-(void)openAddPost{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"addPostNavigationController"];
    AddPostViewController* addPost = (AddPostViewController*)[controller topViewController];
    addPost.delegate =self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)pushCommentControllerWithPost:(Post*) post{
    
    CommentListViewController* controller = [[CommentListViewController alloc] init];
    controller.managedObjectContext =self.managedObjectContext;
    controller.hidesBottomBarWhenPushed = YES;
    controller.automaticallyAdjustsScrollViewInsets = NO;
    controller.post = post;
    [self.navigationController pushViewController:controller animated:YES];

}

-(void)beginLoadPost{
    
}

-(void)endLoadPost:(NSInteger)numberOfPost{
    
    //End refreshing
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }

}

-(void)beginLoadMorePost{
    //Load state, no code because this state is perform automatically
}

-(void)endLoadMorePost:(NSInteger)numberOfPost{
    
    if (numberOfPost==0) {
        [(ViewMoreFooter*)self.tableView.tableFooterView hiddenState];
        
        //Hidding view
        [self.tableView beginUpdates];
        
        [UIView animateWithDuration:0.2 animations:^{
            CGRect newFrame = self.tableView.tableFooterView.frame;
            newFrame.size.height = 0;
            UIView* view  = self.tableView.tableFooterView;
            view.frame = newFrame;
            self.tableView.tableFooterView = view;
            }];
        
        [self.tableView endUpdates];
    }else{
        //Initial state
        [(ViewMoreFooter*)self.tableView.tableFooterView initialState];
    }

}

#pragma mark - Private methods

-(void)loadPostsWithLocation:(CLLocation*)location shouldGetOlders:(BOOL)shouldGetOlders requestDate:(NSDate*)requestDate{
    //CLLocation* hardLocation = [[CLLocation alloc] initWithLatitude:-14.9738785f longitude:-80.9545398f];
    
    if (shouldGetOlders) {
        [self beginLoadMorePost];
    }else{
        [self beginLoadPost];
    }
    
    //First get persistent posts
    [self loadPersistentPostsWhitLocation:location];
    
    //Hide message if it is visible
    if([(PostListView*)self.view isMessageAtTopVisible]){
        [(PostListView*)self.view dismissMessageAtTop];
    }
    
    //Cancel previous requests
    [[SNPostResourceManager sharedManager] cancelGetPosts];

    //Request
    PostListViewController* __weak weakSelf = self;
    [[SNPostResourceManager sharedManager] getPostsWithLocation:location radio:[Preferences UserRadius] date:requestDate username:[Account username] getOlders:shouldGetOlders success:^(NSArray *array) {
        
        NSInteger numberOfPost;
        
        //Update previousRequestDate to last requestDate
        if (array && array.count != 0) {
             numberOfPost = [array count];
        }else{
            numberOfPost = 0;
        }
        
        if (shouldGetOlders) {
            [weakSelf endLoadMorePost:numberOfPost];
        }else{
            [weakSelf endLoadPost:numberOfPost];
        }
       
        //Reload visible rows
        [weakSelf.tableView reloadRowsAtIndexPaths:[weakSelf.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
        
        //Hide message if it is visible
        if([(PostListView*)self.view isMessageAtTopVisible]){
            [(PostListView*)self.view dismissMessageAtTop];
        }
        
    } failure:^(NSError *error) {
        if (shouldGetOlders) {
            [weakSelf endLoadMorePost:0];
        }else{
            [weakSelf endLoadPost:0];
        }
        
        //Show error
        [weakSelf showError:error];
    }];
}

-(void)loadPersistentPostsWhitLocation:(CLLocation*)location{
    NSError *error = nil;
    if (![self.dataSource loadDataWithLocation:location error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
