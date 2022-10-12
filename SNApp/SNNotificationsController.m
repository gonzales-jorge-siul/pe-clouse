//
//  SNChatController.m
//  SNApp
//
//  Created by Force Close on 8/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNNotificationsController.h"
#import "SNGCMService.h"
#import "Chat.h"
#import "Message.h"
#import "Account.h"
#import "SNObjectManager.h"
#import "SNTabViewController.h"
#import "SNLocationManager.h"
#import "SNPostResourceManager.h"
#import "Preferences.h"
#import "SNDate.h"
@interface SNNotificationController ()

@property (nonatomic, weak) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchRequest* chatRequest;
@property (nonatomic, strong) NSFetchRequest* messageRequest;
@property (nonatomic, strong) NSFetchRequest* badgeRequest;
@property (nonatomic, weak) SNTabViewController* tabController;

@end

@implementation SNNotificationController

#pragma mark - Life cycle

+(instancetype)sharedController{
    
    static SNNotificationController* sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedController = [[self alloc] init];
        //[sharedController subscribeToNotifications];
        sharedController.managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    });
    return sharedController;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

-(void)processReceivedNotification:(NSDictionary*)userInfo shouldShowChat:(BOOL)shouldShowChat completionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    if(![userInfo[@"notification"] isEqualToString:@"notice"]){
        [self processChatNotification:userInfo shouldShowChat:shouldShowChat];
        completionHandler(UIBackgroundFetchResultNoData);
    }else{
        if ([[Preferences NotificationNearPost] boolValue]) {
            [self processPostNotification:userInfo];
        }
        
        [[SNPostResourceManager sharedManager] cancelGetPosts];
        [[SNPostResourceManager sharedManager] getPostsWithLocation:[[SNLocationManager sharedInstance] lastLocation] radio:[Preferences UserRadius] date:[SNDate dateWithTimeIntervalSinceServerDate:-10] username:[Account username] success:^(NSArray* success) {
            completionHandler(UIBackgroundFetchResultNewData);
        } failure:^(NSError * error) {
            [[SNPostResourceManager sharedManager] cancelGetPosts];
            completionHandler(UIBackgroundFetchResultNoData);
        } maxNumberOfRepetitions:@1];
    }
}

#pragma mark - Helpers

-(void)processPostNotification:(NSDictionary*) userInfo{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state != UIApplicationStateBackground) {
        return;
    }
    
    //Get notification coordinates and convert to double
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber* latitudeNumber = [formatter numberFromString: userInfo[@"latitude"]];
    NSNumber* longitudeNumber = [formatter numberFromString:userInfo[@"longitude"]];
    
    //Compare with last reported location
    CLLocation* notificationLocation = [[CLLocation alloc] initWithLatitude:[latitudeNumber doubleValue] longitude:[longitudeNumber doubleValue]];
    CLLocation* currentLocation = [[SNLocationManager sharedInstance] lastReportedLocation];
    if ([currentLocation distanceFromLocation:notificationLocation]<500) {
        //Post a notification
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.alertBody = NSLocalizedString(@"notification.post.There are new post around you", nil);
        localNotif.alertTitle = NSLocalizedString(@"notification.post.New post", nil);
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1; 
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}

-(void)processChatNotification:(NSDictionary*) userInfo shouldShowChat:(BOOL)shouldShowChat{
    
    //Create new message object
    NSString *messageContent = userInfo[@"msg"];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *idMessage = [formatter numberFromString:userInfo[@"notification"]];
    NSError* errorMessage;
    Message* message = [self getMessageWithId:idMessage error:&errorMessage];
    if (errorMessage==nil) {
        if (!message) {
            message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
            message.idMessage = idMessage;
            message.message = messageContent;
            message.date = [NSDate date];
            message.type = @(SNReceiver);
            
            NSString *from = userInfo[@"fromusername"];
            NSString *name = userInfo[@"fromname"];
            NSString *photo = userInfo[@"fromphoto"];
            NSString *status = userInfo[@"fromstatus"];
            
            NSError *error;
            Chat *chat = [self getChatForInterlocutor:from error:&error];
            if (error == nil) {
                if (chat) {
                    chat.lastMessage = message.message;
                    chat.date = message.date;
                    chat.isRead = @NO;
                    [chat addMessagesObject:message];
//                    if (chat.messages.count>7) {
//                        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
//                        NSArray* sortSet = [chat.messages sortedArrayUsingDescriptors:@[descriptor]];
//                        [self.managedObjectContext deleteObject:[sortSet firstObject]];
//                    }
                    [self computeAndSetBadge:shouldShowChat];
                }else{
                    Account* account = [self getAccountForUsername:from error:&error];
                    if (error==nil) {
                        if (account) {
                            account.photo = photo;
                            account.name = name;
                            account.status = status;
                        }else{
                            account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
                            account.username = from;
                            account.name = name;
                            account.photo = photo;
                            account.status = status;
                        }
                        
                        Chat* chat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
                        chat.date = message.date;
                        chat.lastMessage = message.message;
                        chat.state =@(SNNormal);
                        chat.interlocutor =account;
                        chat.interlocutorUsername = from;
                        chat.isRead =@NO;
                        [chat addMessagesObject:message];
                        [self computeAndSetBadge:shouldShowChat];
                    }else{
                        //Deal with error
                    }
                }
            }
            else {
                // Deal with error.
            }
        }else{
            //Nothing to do
        }
    }else{
        //Deal with error
    }
    
    if (shouldShowChat) {
        [self.tabController setSelectedIndex:2];
    }
}

-(Chat*)getChatForInterlocutor:(NSString*)interlocutor error:(NSError*__autoreleasing*)error{
    self.chatRequest.predicate = [NSPredicate predicateWithFormat:@"interlocutorUsername==%@",interlocutor];
    NSArray * array = [self.managedObjectContext executeFetchRequest:self.chatRequest error:error];
    if (array) {
        if (array.count==1) {
            return array[0];
        }
    }
    return nil;
}

-(Account*)getAccountForUsername:(NSString*)username error:(NSError*__autoreleasing*)error{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"username == %@",username];
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:error];
    if (array) {
        if (array.count == 1) {
            return array[0];
        }
    }
    return nil;
}

-(Message*)getMessageWithId:(NSNumber*)id error:(NSError*__autoreleasing*)error{
    self.messageRequest.predicate = [NSPredicate predicateWithFormat:@"idMessage==%@",id];
    NSArray* array = [self.managedObjectContext executeFetchRequest:self.messageRequest error:error];
    if(array){
        if(array.count==1){
            return array[0];
        }
    }
    return nil;
}

-(void)computeAndSetBadge:(BOOL)shouldShowChat{
    NSError * error;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:self.badgeRequest error:&error];
    if (!error) {
        if (count>0) {
            [self.tabController addBadgeNumber:@(count)];
            
          
        }
    }
}

#pragma mark - Custom accessors

-(NSFetchRequest *)chatRequest{
    if (!_chatRequest) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
        _chatRequest = request;
    }
    return _chatRequest;
}

-(NSFetchRequest *)messageRequest{
    if (!_messageRequest) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
        _messageRequest = request;
    }
    return _messageRequest;
}


-(NSFetchRequest *)badgeRequest{
    if (!_badgeRequest) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
        request.predicate  = [NSPredicate predicateWithFormat:@"isRead == NO"];
        _badgeRequest = request;
    }
    return _badgeRequest;
}

-(SNTabViewController *)tabController{
    if (!_tabController) {
        UIWindow* window = [[UIApplication sharedApplication] windows][0];
        SNTabViewController* tabController =(SNTabViewController*)[window rootViewController];
        _tabController = tabController;
    }
    return _tabController;
}
@end
