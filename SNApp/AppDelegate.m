//
//  AppDelegate.m
//  SNApp
//
//  Created by JG on 6/11/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "SNGCMService.h"
#import "SNObjectManager.h"
#import "PostDataSourceProtocol.h"
#import "PostListViewController.h"
#import "ChatListTableViewController.h"
#import "PostSortedByDateDataSource.h"
#import "PostSortedByRateDataSource.h"
#import "SNConstans.h"
#import "SNLocationManager.h"
#import "SNLoginController.h"
#import "Message.h"
#import "Chat.h"
#import "Account.h"
#import "SNNotificationsController.h"
#import "SNAccountResourceManager.h"
#import "SNDate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Delete notifications and set app icon badge number to zero
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    
//    UILocalNotification* notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//    if (notification) {
//        NSLog(@"app recieved notification from local: %@",notification.userInfo);
//
//        
//    }else{
//        NSLog(@"app did not recieve notification from local.");
//    }
//    
//     notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (notification) {
//        NSLog(@"app recieved notification from remote: %@",notification.userInfo);
//        [application setApplicationIconBadgeNumber:0];
//        [application cancelAllLocalNotifications];
//        
//    }else{
//        NSLog(@"app did not recieve notification from remote.");
//    }
    
    //Set default values for preferences
    [Preferences setInitialDefaults];
    
    //App flag
    [Preferences setAppFlap:@YES];
    
    //Wake up login controller
    [SNLoginController sharedController];
    
    //Wake up notification controller
    [SNNotificationController sharedController];
    
    //Configure context for google cloud messaging and other apis
    [[SNGCMService sharedInstance] configureContext];
    
    //Register for remote notifications provide by APNS
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge );
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //Start google cloud messaging
    [[SNGCMService sharedInstance] startWithConfiguration];
    
    //Setup initial view controllers
    [self setupViewControllers];
    
    //Delete unused data
    [self deleteUnusedData];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Custom Back button
        UIImage *backButtonBackgroundImage = [UIImage imageNamed:@"backArrowIcon"];
        // The background should be pinned to the left and not stretch.
        backButtonBackgroundImage = [backButtonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonBackgroundImage.size.width , 0, 0)];
        
        id appearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], nil];
        [appearance setBackButtonBackgroundImage:backButtonBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    });
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    NSLog(@"%@\n%ld",tzName,(long)timeZone.secondsFromGMT);
    NSLog(@"%@",[SNDate serverDate]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
//    NSLog(@"%@",@"WILL RESIGN ACTIVE");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self savePersistentData];
    if([[SNLoginController sharedController] verifyIsLogin]){
        [[SNAccountResourceManager sharedManager] lastConnection:[NSDate date] username:[Account username] isConnect:@NO success:nil failure:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%@",@"ENTER FOREGROUND");
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if([[SNLoginController sharedController] verifyIsLogin]){
        [[SNAccountResourceManager sharedManager] lastConnection:[NSDate date] username:[Account username] isConnect:@YES success:nil failure:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self savePersistentData];
    [[SNLocationManager sharedInstance] stopLocationServices];
}

#pragma mark - Notifications

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // When APN's token arrive send to GCM
    [[SNGCMService sharedInstance] getRegistrationTokenWithDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    NSDictionary *userInfo = @{@"error" :error.localizedDescription};
    [[NSNotificationCenter defaultCenter] postNotificationName:GCMRegistrationComplete object:nil userInfo:userInfo];
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    NSLog(@"Notification received: %@", userInfo);
//    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
//    //[[NSNotificationCenter defaultCenter] postNotificationName:GCMMesageReceive object:nil userInfo:userInfo];
//}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    BOOL shouldShowChat = NO;
    NSLog(@"Remote: %@", userInfo);
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
     UIApplicationState state = application.applicationState;
    switch (state) {
        case UIApplicationStateActive:
            NSLog(@"Remote state: Active");
            break;
        case UIApplicationStateBackground:
            [application setApplicationIconBadgeNumber:1];
            NSLog(@"Remote state: Background");
            break;
        case UIApplicationStateInactive:
            [application setApplicationIconBadgeNumber:0];
            [application cancelAllLocalNotifications];
            shouldShowChat = YES;
            NSLog(@"Remote state: Inactive");
            break;
    }
    
    [[SNNotificationController sharedController] processReceivedNotification:userInfo shouldShowChat:shouldShowChat completionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
    }];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"Local: %@",notification.userInfo);
    UIApplicationState state =    application.applicationState;
    switch (state) {
        case UIApplicationStateActive:
            NSLog(@"Remote state: Active");
            break;
        case UIApplicationStateBackground:
            [application setApplicationIconBadgeNumber:1];
            NSLog(@"Remote state: Background");
            break;
        case UIApplicationStateInactive:
            [application setApplicationIconBadgeNumber:0];
            [application cancelAllLocalNotifications];
            NSLog(@"Remote state: Inactive");
            break;
    }
}

#pragma mark - Helpers
-(void)setupViewControllers{
    SNAccountState stateAccount =[[SNLoginController sharedController] verifyAccount];
    switch (stateAccount) {
        case SNAccountStateBlock:
            //Return  because login controller take care of set an appropiate view.
            return;
        default:
            break;
    }
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

    id<PostDataSourceProtocol, UITableViewDataSource> dataSource;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:SNMainStoryboardName bundle:nil];
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:4];
    
    CLLocation* lastLocation = [[SNLocationManager sharedInstance] lastLocation];
    
    PostListViewController *viewController = [[PostListViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    viewController.managedObjectContext =[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    dataSource = [[PostSortedByDateDataSource alloc] initWithManagedObjectContext:[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] location:lastLocation];
    [dataSource setSorted:@(SNPostSortByDate)];
    viewController.dataSource = dataSource;
    [viewControllers addObject:navController];
    
    viewController = [[PostListViewController alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    viewController.managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    dataSource = [[PostSortedByRateDataSource alloc] initWithManagedObjectContext:[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] location:lastLocation];
    [dataSource setSorted:@(SNPostSortByRate)];
    viewController.dataSource = dataSource;
    [viewControllers addObject:navController];
    
    navController = [storyboard instantiateViewControllerWithIdentifier:SNChatStoryboardIdentifier];
    ChatListTableViewController* controller= (ChatListTableViewController*)[navController topViewController];
    controller.tabBarItem.image = [UIImage imageNamed:@"chatIcon"];
    controller.tabBarItem.title = NSLocalizedString(@"chat.title", nil);
    controller.managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    [viewControllers addObject:navController];
    
    navController = [storyboard instantiateViewControllerWithIdentifier:SNSettingsStoryboardIdentifier];
    [viewControllers addObject:navController];
    
    tabBarController.viewControllers = viewControllers;
    [tabBarController setSelectedIndex:0];
}

-(void)savePersistentData{
    //Save persistent data
    NSManagedObjectContext* managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    NSError *error = nil;
    if ([managedObjectContext hasChanges] && ![managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Unresolved error appdelegate %@, %@", error, [error userInfo]);
        //abort();
    }
}

-(void)deleteUnusedData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSManagedObjectContext *correctContext = [[[SNObjectManager sharedManager] managedObjectStore] newChildManagedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType tracksChanges:YES];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Post" inManagedObjectContext:correctContext]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"creationDate < %@ ",[NSDate dateWithTimeIntervalSinceNow:-86400]]];
        [request setIncludesPropertyValues:NO];
        
        NSError* fetchError;
        NSArray *fetchedObjects = [correctContext executeFetchRequest:request error:&fetchError];
        if (!fetchedObjects) {
            NSLog(@"ERROR WHEN DELETE POST:%@",fetchError);
        }else if (fetchedObjects.count>0){
            for (Post* post in fetchedObjects) {
                [correctContext deleteObject:post];
            }
        }
        
        [request setEntity:[NSEntityDescription entityForName:@"Chat" inManagedObjectContext:correctContext]];
        [request setPredicate:nil];
        [request setIncludesPropertyValues:NO];
        
        fetchError = nil;
        fetchedObjects = [correctContext executeFetchRequest:request error:&fetchError];
        fetchedObjects = [fetchedObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ALL messages.date < %@ ",[NSDate dateWithTimeIntervalSinceNow:-86400]]];
        if (!fetchedObjects) {
            NSLog(@"ERROR WHEN DELETE POST:%@",fetchError);
        }else if(fetchedObjects.count>0){
            for (Chat* chat in fetchedObjects) {
                [correctContext deleteObject:chat];
            }
        }
        
        NSError *error;
        if ([correctContext hasChanges] && ![correctContext saveToPersistentStore:&error]) {
            NSLog(@"ERROR WHEN SAVE CONTEXT:%@",error);
        }
    });
}

@end
