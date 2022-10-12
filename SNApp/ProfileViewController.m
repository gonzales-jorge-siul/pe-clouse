//
//  ProfileViewController.m
//  SNApp
//
//  Created by Force Close on 7/4/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileView.h"
#import "ProfileTableViewCell.h"
#import "Chat.h"
#import <LTNavigationBar/UINavigationBar+Awesome.h>
#import "SNPostResourceManager.h"
#import "ReportTableViewController.h"

@interface ProfileViewController ()<UITableViewDelegate,UITableViewDataSource,ReportProtocol>

@property(nonatomic,weak)UITableView* tableView;

@end

@implementation ProfileViewController

NSString* const SNProfileCell = @"SN Profile Cell Reuse Identifier";

NSUInteger const NUMBER_OF_SECTIONS_P = 2;
NSUInteger const NUMBER_OF_ROWS_SECTION_ONE_P = 2;

NSUInteger const NUMBER_OF_ROWS_SECTIONS_TWO_P = 1;

-(void)loadView{
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    ProfileView* profileView = [[ProfileView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.tableView = profileView.tableView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [profileView.sendMessageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.view =profileView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate =self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProfileTableViewCell class] forCellReuseIdentifier:SNProfileCell];
    
    //Add bar button item right
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"userSettingsIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(reportUser:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Make transparent navigation bar
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar  setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setOpaque:NO];
    [self.navigationController.navigationBar setTranslucent:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setOpaque:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar lt_reset];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom accessors
-(void)setAccount:(Account *)account{
    _account =account;
    ProfileView* view = (ProfileView*)self.view;
    view.account = self.account;
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView reloadData];
}

#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 5, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 12.0;
    }
    
    return 1.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return NUMBER_OF_SECTIONS_P;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NUMBER_OF_ROWS_SECTION_ONE_P;
        case 1:
            return NUMBER_OF_ROWS_SECTIONS_TWO_P;
        default:
            return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return [ProfileTableViewCell heightForText:[self contentForRowAtIndexPath:indexPath] frame:self.tableView.bounds];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProfileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SNProfileCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SNProfileCell];
    }
    
    cell.contentLabel.text = [self contentForRowAtIndexPath:indexPath];
    cell.titleLabel.text = [self titleForRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Action
-(IBAction)sendMessage:(id)sender{
    if (self.delegate) {
        [self.delegate profileController:self startChat:self.account];
        return;
    }
    if (self.tabBarController) {
        Chat* chat = [self searchChatWith:self.account];
        if (chat) {
            chat.state = @(SNPending);
        }else{
            Chat* newChat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
            newChat.date =[NSDate date];
            newChat.lastMessage = @"";
            newChat.state = @(SNPending);
            newChat.interlocutor = self.account;
            newChat.interlocutorUsername = self.account.username;
        }
        switch (self.tabBarController.selectedIndex) {
            case 0:
            case 1:
                [self.tabBarController setSelectedIndex:2];
                [self.navigationController popToRootViewControllerAnimated:NO];
                break;
            case 2:
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
        }
    }
}

-(IBAction)reportUser:(id)sender{
    
    UIAlertController* alertController = [[UIAlertController alloc] init];
    //alertController.title = NSLocalizedString(@"app.general.report", nil);
    //alertController.message = NSLocalizedString(@"profile.report-action.alert-message", nil);
    
    ProfileViewController* __weak weakSelf = self;
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* reportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.report", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [weakSelf reportAccount];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:reportAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Helpers

-(Chat*)searchChatWith:(Account*)account{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"interlocutor == %@", account];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    if (fetchedObjects.count>0) {
        return fetchedObjects[0];
    }else{
        return nil;
    }
}

-(NSString*)titleForRowAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return NSLocalizedString(@"profile.category.status", nil);
                case 1:
                    return NSLocalizedString(@"profile.category.age", nil);
                default:
                    return @"";
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return NSLocalizedString(@"profile.category.likes", nil);
                default:
                    return @"";
            }
        default:
            return @"";
    }
}

-(NSString*)contentForRowAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return self.account.status;
                case 1:{
                    NSDate* birthday = self.account.birth;
                    
                    NSDate* now = [NSDate date];
                    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                       components:NSCalendarUnitYear
                                                       fromDate:birthday
                                                       toDate:now
                                                       options:0];
                    NSInteger age = [ageComponents year];
                    
                    return [NSString stringWithFormat:NSLocalizedString(@"profile.content.%ld years old", @"{age} years old"),(long)age];
                }
                default:
                    return @"";
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return self.account.likes;
                default:
                    return @"";
            }
        default:
            return @"";
    }
}

-(void)reportAccount{
    NSNumber* reportedAccountId = self.account.idAccount;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* navController = [storyboard instantiateViewControllerWithIdentifier:@"Report Navigation Controller"];
    ReportTableViewController* reportController = (ReportTableViewController*)[navController topViewController];
    reportController.reportedAccountId = reportedAccountId;
    reportController.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Report protocol
-(void)reportController:(ReportTableViewController *)controller done:(BOOL)done{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (done) {
    }else{
    }
}

@end
