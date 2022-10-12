//
//  SNResponseServerResourceManager.m
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNResponseServerResourceManager.h"
#import "ResponseServer.h"
#import "SNObjectManager.h"
#import "SNExponentialBackoff.h"
#import "Reachability.h"
#import "SNConstans.h"

@interface SNResponseServerResourceManager ()
//Exponetial backoff objects
@property(nonatomic,strong)SNExponentialBackoff *backoffResponseServer;
@property(nonatomic,strong)BOOL(^authenticateBlock)(BOOL lastTime) ;
@property(atomic)BOOL lastTime;
//Reachability object
@property (nonatomic,strong)Reachability* networkReachability;
//Authenticate method parameters
@property(atomic,getter=isParametersSave)BOOL ParametersSave;
@property NSString* number;
//Authenticate method callbacks
@property(nonatomic,strong) void(^success)(ResponseServer* response);
@property(nonatomic,strong) void(^failure)(NSError* error);
//Authenticate method Process
@property(atomic,getter=isInProcess)BOOL inProcess;
//Flag
@property(atomic)BOOL sendMessageFail;
@end

@implementation SNResponseServerResourceManager

NSString* const SNWSAuthenticate = @"/authenticate";

#pragma mark -  Life cycle
+(instancetype)sharedManager{
    static SNResponseServerResourceManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //Initialization
        __sharedInstance = [[self alloc] init];
        [__sharedInstance setupResponseDescriptor];
        //Backoff initialization
        __sharedInstance.backoffResponseServer =[[SNExponentialBackoff alloc]initWithMaxNumberOfRepetitions:@6 multiplier:2.0 ];
        __sharedInstance.backoffResponseServer.handlertime = __sharedInstance.authenticateBlock;
        //Subscribe to reachability changes
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        __sharedInstance.networkReachability =[Reachability reachabilityForInternetConnection];
        [__sharedInstance.networkReachability startNotifier];
        //Allow send message fail
        __sharedInstance.sendMessageFail =YES;
    });
    return __sharedInstance;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.networkReachability stopNotifier];
}

#pragma mark - Public
-(void)authenticatePhone:(NSString *)number success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    self.number =number;
    self.success =success;
    self.failure =failure;
    self.sendMessageFail =YES;
    self.ParametersSave=YES;
    [self authenticatePhone];
}
-(void)cancelAuthenticationPhone{
    if ([self isInternetReachable]) {
        if ([self isInProcess]) {
            NSLog(@"%@",@"Cancel");
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:SNWSAuthenticate];
        }
        if ([self.backoffResponseServer isStart]) {
            [self.backoffResponseServer stop];
        }
        [self deleteParameters];
    }else{
        [self deleteParameters];
        if ([self.backoffResponseServer isStart]) {
            [self.backoffResponseServer stop];
        }
    }
}

#pragma mark - Private
-(void)authenticatePhone{
    if ([self isInternetReachable]) {
        self.inProcess =YES;
        SNResponseServerResourceManager* __weak weakSelf = self;
        [[SNObjectManager sharedManager] postObject:nil path:SNWSAuthenticate parameters:[self buildParameterWithNumber:self.number] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            weakSelf.inProcess = NO;
            if (weakSelf.backoffResponseServer.isStart) {
                [weakSelf.backoffResponseServer stop];
            }
            if (weakSelf.success) {
                ResponseServer* response = [mappingResult.array firstObject];
                weakSelf.success(response);
            }
            [weakSelf deleteParameters];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"%@",@"Failure");
            weakSelf.inProcess = NO;
            if (weakSelf.lastTime) {
                [weakSelf.backoffResponseServer stop];
                weakSelf.lastTime = NO;
                if (weakSelf.failure) {
                    NSError* error;
                    NSString* description = NSLocalizedString(@"app.error.no-server-connection", nil);
                    NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                    error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoServer userInfo:userInfo];
                    weakSelf.failure(error);
                }
                [weakSelf deleteParameters];
            }else{
                if (!weakSelf.backoffResponseServer.isStart) {
                    [weakSelf.backoffResponseServer start];
                }else{
                    [weakSelf.backoffResponseServer resume];
                }
            }
        }];
    }
    else{
        if (self.backoffResponseServer.isStart) {
            [self.backoffResponseServer stop];
        }
        if (self.failure) {
            if (self.sendMessageFail) {
                self.sendMessageFail =NO;
                NSError* error;
                NSString* description = NSLocalizedString(@"app.error.no-internet-connection", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoInternet userInfo:userInfo];
                self.failure(error);
            }
        }
    }
}

#pragma mark - Custom accessors
-(BOOL (^)(BOOL))authenticateBlock{
    if (!_authenticateBlock) {
        __weak typeof(self) weakself = self;
        _authenticateBlock =^BOOL(BOOL lastTime){
            weakself.lastTime =lastTime;
            [weakself.backoffResponseServer pause];
            [weakself authenticatePhone];
            return NO;
        };
    }
    return _authenticateBlock;
}

#pragma mark - Helpers
-(void)setupResponseDescriptor{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSAuthenticate keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}
-(NSDictionary*)buildParameterWithNumber:(NSString *)number{
    return @{@"number":number};
}
-(void)deleteParameters{
    self.ParametersSave =NO;
    self.number = nil;
    self.success =nil;
    self.failure=nil;
}
-(BOOL)isInternetReachable{
    NetworkStatus networkStatus = [self.networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}
- (void) reachabilityChanged:(NSNotification *)note{
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            [self noReachableTask];
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            [self reachableTask];
            break;
            
    }
}
-(void)noReachableTask{
    if (self.inProcess) {
        NSLog(@"%@",@"Cancel no reachable task");
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:SNWSAuthenticate];
        if ([self.backoffResponseServer isStart]) {
            [self.backoffResponseServer stop];
        }
    }else{
        if ([self.backoffResponseServer isStart]) {
            [self.backoffResponseServer stop];
        }
    }
    if (self.failure) {
        if (self.sendMessageFail){
            self.sendMessageFail =NO;
            NSError* error;
            NSString* description = NSLocalizedString(@"app.error.no-internet-connection", nil);
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
            error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoInternet userInfo:userInfo];
                self.failure(error);
        }
    }
}
-(void)reachableTask{
    self.sendMessageFail =YES;
    if (self.isParametersSave) {
        if (!self.inProcess) {
            [self authenticatePhone];
        }
    }
}

@end
