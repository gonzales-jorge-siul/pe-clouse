//
//  ChatListTableViewController.m
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ChatListTableViewController.h"
#import <CoreData/CoreData.h>
#import "Chat.h"
#import "Message.h"
#import "Account.h"
#import "ChatViewController.h"
#import "SNGCMService.h"
#import "ChatListTableViewCell.h"
#import "UIColor+SNColors.h"
#import "SearchTableViewController.h"
#import "AddPostViewController.h"
#import "Preferences.h"

@interface ChatListTableViewController ()<NSFetchedResultsControllerDelegate,AddPostProtocol>

@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property(nonatomic,strong)ChatViewController* chatController;

@property(nonatomic,strong)UIView* parentView;
@property(nonatomic,strong)UIImageView* backgroundView;
@property(nonatomic,strong)UIImageView* floorBackgroundView;
@property(nonatomic,strong)UIButton* buttonBackground;
@property(nonatomic,strong)UILabel* label;

@end

@implementation ChatListTableViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self performFetch];
    [self setupView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"chat.title", nil);
    self.navigationItem.title = NSLocalizedString(@"chat.title", nil);
    
    self.navigationController.navigationBar.barTintColor = [UIColor appMainColor];
    self.navigationController.navigationBar.opaque =YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //Set badge value to zero
    self.tabBarItem.badgeValue = nil;
    
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.tableView.backgroundView = self.parentView;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for (Chat* item in [self.fetchedResultsController fetchedObjects]) {
        if ([item.state isEqualToNumber:@(SNPending)]) {
            self.chatController.chat = item;
            [self showMessage];
            return;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    self.chatController.chat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self showMessage];
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
    if (numberOfRows==0) {
        [self shouldShowBackground:YES];
    }else{
        [self shouldShowBackground:NO];
    }
    return numberOfRows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListTableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:@"Chat List Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(ChatListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Chat* chat =  [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.chat =chat;
}
#pragma mark - Custom accessors
-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController == nil) {
            // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
            // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(messages.@count>0) OR state == %@", @(SNPending)]];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        }
    return _fetchedResultsController;
}
-(ChatViewController *)chatController{
    if (!_chatController) {
        ChatViewController* controller = [[ChatViewController alloc] init];
        controller.managedObjectContext = self.managedObjectContext;
        _chatController =controller;
    }
//    _chatController.isViewLoaded?NSLog(@"YES"):NSLog(@"No");
    return _chatController;
}

-(UIView *)parentView{
    if (!_parentView) {
        UIView*  parentView = [[UIView alloc] initWithFrame:self.view.bounds];
        parentView.backgroundColor = [UIColor whiteColor];
        [parentView addSubview:self.floorBackgroundView];
        [parentView addSubview:self.buttonBackground];
        [parentView addSubview:self.backgroundView];
        [parentView addSubview:self.label];
        _parentView = parentView;
    }
    return _parentView;
}
-(UIImageView *)backgroundView{
    if (!_backgroundView) {
        UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backgroundView.bounds = CGRectMake(0, 0, 44, 44);
        backgroundView.center = CGPointMake(self.view.bounds.size.width +22, self.buttonBackground.center.y);
        
        backgroundView.image = [[UIImage imageNamed:@"sendIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        backgroundView.tintColor = [UIColor appMainColor];
        
        backgroundView.contentMode = UIViewContentModeCenter;
//        backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
//        backgroundView.layer.shadowOpacity = .7f;
//        backgroundView.layer.shadowOffset = CGSizeMake(.1, .1);
        backgroundView.transform = CGAffineTransformMakeRotation(-M_PI/8);
        _backgroundView = backgroundView;
    }
    return _backgroundView;
}
-(UIImageView *)floorBackgroundView{
    if (!_floorBackgroundView) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBackground"]];
        CGSize imageSize = imageView.image.size;
        CGSize size = self.view.bounds.size;
        CGFloat scale = size.width/imageSize.width;
        CGFloat height = imageSize.height*scale;
        CGFloat width = imageSize.width*scale;
        imageView.frame = CGRectMake(0, self.view.bounds.size.height - height, width, height);
        _floorBackgroundView = imageView;
    }
    return _floorBackgroundView;
}
-(UIButton *)buttonBackground{
    if (!_buttonBackground) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"searchIcon"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor appMainColor];
        button.bounds = CGRectMake(0, 0, 50, 50);
        button.frame = CGRectMake(self.view.bounds.size.width/2.f - 25 ,self.label.frame.origin.y + self.label.frame.size.height + 10, 50, 50);
        button.layer.cornerRadius = 25.f;
//        button.layer.shadowColor = [[UIColor blackColor] CGColor];
//        button.layer.shadowOpacity = .7f;
//        button.layer.shadowOffset = CGSizeMake(2, 2);
//        button.transform =CGAffineTransformMakeScale(0.05, 0.05);
        _buttonBackground = button;
    }
    return _buttonBackground;
}
-(UILabel *)label{
    if (!_label) {
        NSString* text = NSLocalizedString(@"chat.background-message.There are not chats", nil);
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20]} context:nil].size;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.bounds = CGRectMake(0, 0, self.view.frame.size.width, textSize.height);
        label.center = CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f -80);
        label.font = [UIFont boldSystemFontOfSize:20.f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1.f];
        label.numberOfLines = 0;
        label.text = text;
        _label = label;
    }
    return _label;
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
            [self configureCell:(ChatListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

-(IBAction)addPost:(id)sender{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"addPostNavigationController"];
    AddPostViewController* addPost = (AddPostViewController*)[controller topViewController];
    addPost.delegate =self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)search:(id)sender{
    SearchTableViewController* controller = [[SearchTableViewController alloc] init];
    controller.managedObjectContext =self.managedObjectContext;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Add post protocol

-(void)didDone:(BOOL)done{
    if (done) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Helpers

-(void)showMessage{
    self.chatController.hidesBottomBarWhenPushed = YES;
    self.chatController.extendedLayoutIncludesOpaqueBars = NO;
    
    [self.navigationController pushViewController:self.chatController animated:YES];
}

-(void)setupView{
    
    //Add bar button item left
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addPostIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(addPost:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    //Add bar button item right
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //back button without title
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    self.tableView.rowHeight = 84;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor gray200Color];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 84, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blueA400Color];
    self.navigationController.navigationBar.opaque =YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

-(void)performFetch{
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)shouldShowBackground:(BOOL)value{
    if (value) {
        [self.label setAlpha:1.0f];
        [self.buttonBackground setAlpha:1.0f];
        if ([[Preferences AppFlag] boolValue]) {
            [self makeAnimation];
            [Preferences setAppFlap:@(NO)];
        }
    }else{
        [self.label setAlpha:0.0f];
        [self.buttonBackground setAlpha:0.0f];
    }
}

-(void)makeAnimation{
    
    //Initial state of animation
    self.buttonBackground.transform = CGAffineTransformMakeScale(.005f, .005f);
    
    //Variables
    CGFloat radiusx;
    CGFloat radiusy = 25;
    CGFloat totalWidth = self.view.bounds.size.width;
    
    CGRect imageFrame = self.backgroundView.frame;
    CGFloat x = imageFrame.origin.x;
    CGFloat y = imageFrame.origin.y;
    CGFloat width = imageFrame.size.width;
    CGFloat height = imageFrame.size.height;
    
    //Compute inital coordinates
    CGFloat initialX = totalWidth - x - width/2.f ;
    CGFloat initialY = y + height/2.f;
    
    //Compute radius x
    radiusx = (totalWidth - 2*initialX)/4.f;
    
    //Trace path
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath,NULL,initialX,initialY);
    CGPathAddCurveToPoint(thePath,NULL,initialX,initialY-radiusy,initialX+2*radiusx,initialY -radiusy,initialX+2*radiusx,initialY);
    CGPathAddCurveToPoint(thePath,NULL,initialX+2*radiusx,initialY+radiusy,initialX+4*radiusx,initialY+radiusy,initialX+4*radiusx,initialY);
    CGPathMoveToPoint(thePath, NULL, initialX+4*radiusx, initialY);
    
    //Animation 1 traslation
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = thePath;
    pathAnimation.duration = 2.f;
    
    // Animation 2 rotation
    CGFloat rotationAngle = M_PI/8;
    CAKeyframeAnimation *showAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    showAnimation.additive = YES; // Make the values relative to the current value
    showAnimation.values = @[ @0,@(rotationAngle),@(2*rotationAngle),@(rotationAngle),@(0)];
    showAnimation.duration = 2.f;
    
    // Animation group
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:pathAnimation, showAnimation, nil];
    group.duration = 2.0;
    
    //Add animation
    [self.backgroundView.layer addAnimation:group forKey:@"myCircleAnimation"];
    
    //Animate button
    ChatListTableViewController* __weak weakSelf = self;
//    [UIView animateWithDuration:2.1f animations:^{
//
//    } completion:^(BOOL finished) {
////        weakSelf.backgroundView.layer.shadowOpacity = 0;
//    }];
    
    [UIView animateWithDuration:1.f delay:1.f options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.buttonBackground.transform = CGAffineTransformMakeScale(1.f, 1.f);
    } completion:nil];
}

@end
