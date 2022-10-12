//
//  ChatViewController.m
//  SNApp
//
//  Created by Jorge Gonzales on 7/5/15.
//  Copyright (c) 2015 Jorge Gonzales. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatView.h"
#import <CoreData/CoreData.h>
#import "ChatTableViewCell.h"
#import "SNAccountResourceManager.h"
#import "SNChatResourceManager.h"
#import "Message.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ProfileViewController.h"
#import "ChatTitleView.h"
#import "UserLastConnection.h"

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,SNProfileDelegate>

@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSFetchedResultsController* fetchedResultsController;
@property(nonatomic,strong)UITextField* messageView;
@property(nonatomic,strong)UIImageView* photoView;
@property(nonatomic)BOOL keepChat;
@property(nonatomic,strong)ChatView* chatView;
//@property(nonatomic,strong)UILabel* footerChatView;
@property(nonatomic,weak)ChatTitleView* titleView;

@end

@implementation ChatViewController

#pragma mark - Life cycle

-(void)loadView{
    [super loadView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.chatView = [[ChatView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.tableView = self.chatView.tableView;
    [self.chatView.button addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.messageView = self.chatView.text;
    self.view = self.chatView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"Chat Cell"];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [button addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:self.photoView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    //Custom title view
    
    NSError* error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
//    if (!self.footerChatView) {
//        self.footerChatView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 24)];
//        self.footerChatView.textAlignment = NSTextAlignmentCenter;
//        self.footerChatView.textColor = [UIColor grayColor];
//        self.footerChatView.font = [UIFont systemFontOfSize:16];
//        self.tableView.tableFooterView = self.footerChatView;
//    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.messageView.isFirstResponder) {
        [self.messageView resignFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    if (!self.keepChat) {
        self.chat.state = @(SNNormal);
        if (self.chat.messages.count==0) {
            [self.managedObjectContext deleteObject:self.chat];
        }
    }
    self.keepChat = NO;
    
    if (self.messageView.isFirstResponder) {
        [self.messageView resignFirstResponder];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@",@"CHAT MEMORY WARNING");
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    if (!parent) {
        [self cancelLoadMessages];
//        [self.chat removeObserver:self forKeyPath:@"date"];
        self.chat.isRead = @YES;
        [self saveChatPersistentStoreSNApp];
    }
}

-(void)saveChatPersistentStoreSNApp{
    NSError* error;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Save error:%@",error);
    }
}

#pragma mark - Key value observing
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"date"]) {
//        self.footerChatView.text = [self textForDate:((Chat*)object).date];
//    }
//}

#pragma mark - Custom accesors

-(void)setChat:(Chat *)chat{
    _chat =chat;
    [self.photoView setImageWithURL:[NSURL URLWithString:self.chat.interlocutor.photo] placeholderImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    //self.navigationItem.title = self.chat.interlocutor.name;
    self.titleView.title = self.chat.interlocutor.name;
    self.titleView.userLastConnection = nil;
    //self.title = self.chat.interlocutor.name;
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self loadPersistentMessages];
    //load messages
    [self loadMessages];
    if (self.chat.messages.count!=0) {
//        self.footerChatView.text = [self textForDate:self.chat.date];
    }
    
    ChatViewController* __weak weakSelf =self;
    [[SNAccountResourceManager sharedManager] getLastConnectionFor:self.chat.interlocutorUsername success:^(UserLastConnection *response) {
        weakSelf.titleView.userLastConnection = response;
    } failure:nil];
    
//    [self.chat addObserver:self forKeyPath:@"date" options:NSKeyValueObservingOptionNew context:nil];
}

-(UIImageView *)photoView{
    if (!_photoView) {
        UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        view.layer.cornerRadius =4.f;
        view.clipsToBounds = YES;
        _photoView = view;
    }
    return _photoView;
}

-(ChatTitleView *)titleView{
    if (!_titleView) {
        ChatTitleView* titleView = [[ChatTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        self.navigationItem.titleView = titleView;
        _titleView = titleView;
    }
    return _titleView;
}

#pragma mark - Actions
-(IBAction)sendMessage:(id)sender{
    
    //Process message
    NSString* processedMessage = [self processMessage:self.messageView.text];
    if ([processedMessage isEqualToString:@""]) {
        return;
    }
    
    //Create a new message object
    Message* message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    message.message = processedMessage;
    message.date = [NSDate date];
    message.type =@(SNSender);
    
    //Make request
    [self sendMessageObject:message];
    
    //Clean message text box
    self.messageView.text =@"";
}

-(void)sendMessageObject:(Message*)message{
    //Update chat parent
    self.chat.lastMessage = message.message;
    self.chat.date = message.date;
    
    [self.chat addMessagesObject:message];
    
    //Make request
//    ChatViewController* __weak weakSelf = self;
    [[SNChatResourceManager sharedManager] sendMessage:message.message from:[Account username] to:self.chat.interlocutor.username success:^(ResponseServer *response) {
        if (!message) {
            return ;
        }
        if ([response.response isEqualToString:@"Success"]) {
            message.sendState = @(SNSendStateSent);
        }else{
            message.sendState = @(SNSendStateFail);
        }
        
    } failure:^(NSError *error) {
        if (!message) {
            return ;
        }
        message.sendState = @(SNSendStateFail);
//        [weakSelf cancelSendMessage];
    }];
}

-(IBAction)showProfile:(id)sender{
    ProfileViewController* controller = [[ProfileViewController alloc] init];
    controller.account= self.chat.interlocutor;
    controller.managedObjectContext = self.managedObjectContext;
    controller.delegate = self;
    self.keepChat = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Message* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([message.type integerValue] == SNSender && [message.sendState integerValue] == SNSendStateFail) {
        message.date = [NSDate date];
        message.sendState = @(SNSendStateSending);
        [self sendMessageObject:message];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Data source

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [ChatTableViewCell heightForText:message frame:self.tableView.bounds];
}

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
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chat Cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Chat Cell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}
- (void)configureCell:(ChatTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Message* message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.message = message;
}

#pragma mark - Custom accessors
-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController == nil) {
        // Create the fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
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
    NSInteger numberOfRows = [controller fetchedObjects].count;
    if (numberOfRows>7) {
        NSIndexPath *indexPathC = [NSIndexPath indexPathForRow:0 inSection:0];
        [controller.managedObjectContext deleteObject:[controller objectAtIndexPath:indexPathC]];
    }else{
        [self scrollToBottom];
    }
}

-(void)scrollToBottom{
    NSInteger numberOfRows = [self.fetchedResultsController fetchedObjects].count;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(ChatTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Profile view delegate

-(void)profileController:(ProfileViewController *)controller startChat:(Account *)account{
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Helpers

-(void)loadPersistentMessages{
    // Add the predicate for the current chat    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(chat == %@) AND (date > %@)",self.chat , [NSDate dateWithTimeIntervalSinceNow:-84600]];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}

-(void)loadMessages{
    ChatViewController* __weak weakSelf = self;
    [[SNChatResourceManager sharedManager] getChats:[Account username] interlocutor:self.chat.interlocutorUsername date:[NSDate dateWithTimeIntervalSinceNow:-84600] success:^(NSArray *data) {
        
        if (data && data.count>0) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
            data = [data sortedArrayUsingDescriptors:@[sortDescriptor]];
            Message* message = [data firstObject];
        
            if ( !weakSelf.chat.date || ([weakSelf.chat.date compare:message.date] == NSOrderedAscending)) {
                weakSelf.chat.lastMessage = message.message;
                weakSelf.chat.date = message.date;
            }
        }
        
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}
-(void)cancelLoadMessages{
    [[SNChatResourceManager sharedManager] cancelGetChats];
}
-(void)cancelSendMessage{
    [[SNChatResourceManager sharedManager] cancelSendMessage];
}

-(NSString*)textForDate:(NSDate*)date{
    double secondsInPost = [date timeIntervalSinceNow];
    if (secondsInPost<0) {
        secondsInPost = -1*secondsInPost;
        if (secondsInPost<60) {
            int seconds = secondsInPost;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.footer.last message %dsec ago", @"last message {number of seconds} ago"),seconds];
        }else if(secondsInPost<3600){
            int minutes = secondsInPost/60;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.footer.last message %dmin ago", @"last message {number of minutes} ago"),minutes];
        }else if(secondsInPost<86400){
            int hours = secondsInPost/3600;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.footer.last message %dh ago", @"last message {number of hours} ago"),hours];
        }else if (secondsInPost<604800){
            int days = secondsInPost/86400;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.footer.last message %dd ago", @"last message {number of days} ago"),days];
        }else{
            int weeks = secondsInPost/604800;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.footer.last message %dw ago", @"last message {number of weeks} ago"),weeks];
        }
    }else{
        return NSLocalizedString(@"app.general.At future", @"just for test");
    }
}


-(NSString*)processMessage:(NSString*)message{
    NSString* toProcess;
    int count= (int)message.length;
    for (int i = 0 ; i<count ; i++) {
        toProcess=[message substringFromIndex:(message.length-1)];
        if ([toProcess isEqualToString:@" "]) {
            message = [message substringToIndex:message.length -1];
        }else{
            break;
        }
    }
    return message;
}

@end
