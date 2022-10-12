//
//  SNGCMService.m
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNGCMService.h"
#import "Preferences.h"
#import "Reachability.h"
#import "SNExponentialBackoff.h"

@interface SNGCMService ()

@property (nonatomic,strong)void(^registrationHandler)(NSString* registrationToken, NSError *error);
@property (nonatomic,strong)NSDictionary* registrationOptions;
@property (nonatomic,strong)NSNumber* networkConnection;
@property (nonatomic,strong)Reachability* networkReachability;

@property(nonatomic,strong)NSMutableDictionary* connectionTasks;

//test
@property (nonatomic,strong)SNExponentialBackoff* backoffConnect;
@property(nonatomic,strong)SNExponentialBackoff* backoffGetToken;

@property(nonatomic,strong)BOOL(^connectBlock)(BOOL lastTime);
@property(nonatomic,strong)BOOL(^getTokenBlock)(BOOL lastTime);

@end

@implementation SNGCMService

NSString* const GCMMesageReceive=@"GCMmessageReceive";
NSString* const GCMRegistrationComplete=@"GCMRegistrationComplete";

NSString* const kTryConnectGCM=@"tryConnectGCM";
NSString* const kTryGetToken=@"tryGetToken";

+(instancetype)sharedInstance{
    static SNGCMService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[self alloc] init];
       
        sharedInstance.connectionTasks = [NSMutableDictionary dictionaryWithDictionary:@{kTryConnectGCM:@NO,kTryGetToken:@NO}];
        
        [Preferences setGCMIsReceivedToken:@NO];
        [Preferences setGCMIsConnect:@NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        sharedInstance.networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [sharedInstance.networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            sharedInstance.networkConnection = @NO;
        } else {
            sharedInstance.networkConnection =@YES;
        }
        [sharedInstance.networkReachability startNotifier];
        
        sharedInstance.backoffConnect =[[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:@8 multiplier:1.5];
        sharedInstance.backoffConnect.handlertime = sharedInstance.connectBlock;
        sharedInstance.backoffGetToken = [[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:@8 multiplier:1.5];
        sharedInstance.backoffGetToken.handlertime = sharedInstance.getTokenBlock;
        
    });
    return sharedInstance;
}

-(void (^)(NSString *, NSError *))registrationHandler{

    __weak typeof(self) weakSelf = self;
    _registrationHandler = ^(NSString* registrationToken, NSError *error){
        if (!error) {
            NSLog(@"%@",registrationToken);
//            [Preferences setUserCloudId:registrationToken];
            [weakSelf setGCMIsReceivedToken];
            [weakSelf.connectionTasks setObject:@NO forKey:kTryGetToken];
            
             NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:GCMRegistrationComplete
                                                                object:nil
                                                              userInfo:userInfo];
            if (weakSelf.backoffGetToken.isStart) {
                [weakSelf.backoffGetToken stop];
            }
        }else{
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            if (!weakSelf.backoffGetToken.isStart) {
                [weakSelf.backoffGetToken start];
            }else{
                [weakSelf.backoffGetToken resume];
            }
        }
    };
    return _registrationHandler;
}

-(void)connect{
    if ([[self networkConnection] boolValue]) {
        SNGCMService* __weak weakSelf = self;
     [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
            if (!weakSelf.backoffConnect.isStart) {
                [weakSelf.backoffConnect start];
            }else{
                [weakSelf.backoffConnect resume];
            }
        } else {
            [weakSelf setGCMIsConnect];
            [weakSelf.connectionTasks setObject:@NO forKey:kTryConnectGCM];
            NSLog(@"Connected to GCM");
            if (weakSelf.backoffConnect.isStart) {
                [weakSelf.backoffConnect stop];
            }
        }
     }];
    }else{
        [self.connectionTasks setObject:@"YES" forKey:kTryConnectGCM];
    }
}

-(void)disconnect{
    [[GCMService sharedInstance] disconnect];
    [Preferences setGCMIsConnect:@NO];
}

-(void)getRegistrationToken{
    if ([[self networkConnection] boolValue]) {
        [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:[Preferences GCMSenderId]
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:[self registrationOptions]
                                                      handler:[self registrationHandler]];
    }else{
        [self.connectionTasks setObject:@"YES" forKey:kTryGetToken];
    }
}

-(void)getRegistrationTokenWithDeviceToken:(NSData*) deviceToken{
    [[GGLInstanceID sharedInstance] startWithConfig:[GGLInstanceIDConfig defaultConfig]];
    self.registrationOptions =  @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                                  kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    
    [self getRegistrationToken];
}

#pragma mark - Helpers

-(void)configureContext{
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    if (configureError != nil) {
        //development-time
        NSLog(@"Error configuring the Google context: %@", configureError);
    }
    NSString* senderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    [Preferences setGCMSenderId:senderID];
}

-(void)startWithConfiguration{
    [[GCMService sharedInstance] startWithConfig:[GCMConfig defaultConfig]];
}

#pragma mark -  GGL instance id delegate;
//Implement notification when receiced token
-(void)onTokenRefresh{
    [Preferences setGCMIsReceivedToken:@NO];
    [self getRegistrationToken];
}

#pragma mark - Internet Connection
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    //NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            self.networkConnection=@NO;
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            self.networkConnection = @YES;
            if ([[self.connectionTasks objectForKey:kTryGetToken] boolValue]) {
                [self getRegistrationToken];
            }
            if ([[self.connectionTasks objectForKey:kTryConnectGCM] boolValue]) {
                [self connect];
            }
            break;
        
    }
}

#pragma mark - Backoff

-(BOOL (^)(BOOL))connectBlock{
    if (!_connectBlock) {
        __weak typeof(self) weakSelf = self;
        _connectBlock = ^BOOL(BOOL lastTime){
            [weakSelf.backoffConnect pause];
            [weakSelf connect];
            return NO;
        };
    }
    return _connectBlock;
}

-(BOOL (^)(BOOL))getTokenBlock{
    if (!_getTokenBlock) {
        __weak typeof(self) weakSelf =self;
        _getTokenBlock = ^BOOL(BOOL lastTime){
            [weakSelf.backoffGetToken pause];
            [weakSelf getRegistrationToken];
            return NO;
        };
    }
    return _getTokenBlock;
}

#pragma mark - Helpers blocks
-(void)setGCMIsReceivedToken{
    [Preferences setGCMIsReceivedToken:@YES];
}

-(void)setGCMIsConnect{
    [Preferences setGCMIsConnect:@YES];
}

@end
