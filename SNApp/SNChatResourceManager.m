//
//  SNChatResourceManager.m
//  SNApp
//
//  Created by Force Close on 8/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNObjectManager.h"
#import "SNChatResourceManager.h"
#import "SNExponentialBackoff.h"
#import "SNConstans.h"
#import "Reachability.h"

@interface SNChatResourceManager ()

//Method's parameters
@property(nonatomic,strong)NSMutableDictionary* saveParameters;
@property(nonatomic,strong)NSMutableDictionary* parameters;

//Flags
@property(nonatomic,strong)NSMutableDictionary* canSendMessageFail;
@property(nonatomic,strong)NSMutableDictionary* inProcess;

//Backoff
@property(nonatomic,strong)NSMutableDictionary* backoff;
@property(nonatomic,strong)NSMutableDictionary* backoffBlock;

//Reachability object
@property (nonatomic,strong)Reachability* networkReachability;

//Previus connection state
@property(nonatomic)BOOL previusConnectionState;

@end

@implementation SNChatResourceManager


#pragma mark - Constants
//Services
NSString* const SNWSGetChats=@"/getLastMessage";
NSString* const SNWSSendMessage = @"/send";
//Keys
NSString* const kGetChatsKey=@"GetChatsKey";
NSString* const kSendMessageKey = @"SendMessageKey";

//Get comment
NSString* const kGetChatsUsernameParameter = @"GetChatsUsernameParameter";
NSString* const kGetChatsInterlocutorParameter = @"GetChatsInterlocutorParameter";
NSString* const kGetChatsDateParameter = @"GetChatsDateParameter";
NSString* const kGetChatsSuccessParameter = @"GetChatsSuccessParameter";

//Send messages
NSString* const kSendMessageParameter = @"SendMessageParameter";
NSString* const kSendMessageFromUserParameter = @"SendMessageFromUserParameter";
NSString* const kSendMessageToUserParameter = @"SendMessageToUserParameter";
NSString* const kSendMessageSuccessParameter = @"SendMessageSuccessParameter";

//Failure parameter
NSString* const kFailureParameterChats = @"FailureParameterChats";

#pragma mark - Life cycle
+(instancetype)sharedManager{
    static SNChatResourceManager* sharedManager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //Initialization
        sharedManager = [[self alloc] init];
        [sharedManager setupResponseDescriptors];
        sharedManager.parameters =[[NSMutableDictionary alloc] init];
        sharedManager.saveParameters = [NSMutableDictionary dictionaryWithDictionary:@{kGetChatsKey:@NO,kSendMessageKey:@NO}];
        sharedManager.canSendMessageFail = [NSMutableDictionary dictionaryWithDictionary:@{kGetChatsKey:@NO,kSendMessageKey:@NO}];
        sharedManager.inProcess =[NSMutableDictionary dictionaryWithDictionary:@{kGetChatsKey:@NO,kSendMessageKey:@NO}];
        sharedManager.backoff = [[NSMutableDictionary alloc] init];
        sharedManager.backoffBlock = [[NSMutableDictionary alloc] init];
        //Subscribe to reachability changes
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        sharedManager.networkReachability =[Reachability reachabilityForInternetConnection];
        [sharedManager.networkReachability startNotifier];
    });
    return sharedManager;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.networkReachability stopNotifier];
}

#pragma mark - Public

-(void)getChats:(NSString *)aUsername interlocutor:(NSString *)aInterlocutor date:(NSDate *)date success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
        NSArray* parametersArray = @[aUsername,aInterlocutor,date,success,failure];
        NSArray* keysArray= @[kGetChatsUsernameParameter,kGetChatsInterlocutorParameter,kGetChatsDateParameter,kGetChatsSuccessParameter,kFailureParameterChats];
        NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
        [self.parameters setObject:parameters forKey:kGetChatsKey];
        [self.canSendMessageFail setObject:@YES forKey:kGetChatsKey];
        [self.saveParameters setObject:@YES forKey:kGetChatsKey];
        [self loadDataForKey:kGetChatsKey];
}
-(void)cancelGetChats{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetChatsKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetChats];
        }
    }
    [self stopBackoffForKey:kGetChatsKey];
    [self deleteParametersForKey:kGetChatsKey];
}


-(void)sendMessage:(NSString *)message from:(NSString *)fromUsername to:(NSString *)toUsername success:(void (^)(ResponseServer *response))success failure:(void (^)(NSError *))failure{
//  Get support for multi-saving
//    NSArray* parametersArray = @[message,fromUsername,toUsername,[self verifyParameter:success],[self verifyParameter:failure]];
//    NSArray* keysArray= @[kSendMessageParameter,kSendMessageFromUserParameter, kSendMessageToUserParameter,kSendMessageSuccessParameter,kFailureParameterChats];
//    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
//    [self.parameters setObject:parameters forKey:kSendMessageKey];
//    [self.canSendMessageFail setObject:@YES forKey:kSendMessageKey];
//    [self.saveParameters setObject:@YES forKey:kSendMessageKey];
//    [self loadDataForKey:kSendMessageKey];
    
    
    [[SNObjectManager sharedManager] postObject:nil path:[self pathForKey:kSendMessageKey] parameters:[self buildParameterWithMessage:message fromUsername:fromUsername toUsername:toUsername] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            success([[mappingResult array] firstObject]);
        }

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (operation.HTTPRequestOperation.isCancelled) {
            return ;
        }
        if (failure) {
            NSError* error;
            NSString* description = NSLocalizedString(@"app.error.no-server-connection", nil);
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
            error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoServer userInfo:userInfo];
            failure(error);
        }
    }];
    
}
-(void)cancelSendMessage{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kSendMessageKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSSendMessage];
        }
    }
    [self stopBackoffForKey:kSendMessageKey];
    [self deleteParametersForKey:kSendMessageKey];
}

#pragma mark - Private
-(void)loadDataForKey:(NSString*)aKey{
    if ([self isInternetReachable]) {
        [self.inProcess setObject:@YES forKey:aKey];
        SNChatResourceManager* __weak weakSelf = self;
        [[SNObjectManager sharedManager] postObject:nil path:[self pathForKey:aKey] parameters:[self buildParametersForKey:aKey] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
            ///////////////////////
            if ([aKey isEqualToString:kGetChatsKey]) {
                void(^success)(NSArray* response) = [weakSelf parameterForMethod:kGetChatsKey key:kGetChatsSuccessParameter];
                if (success) {
                    success([mappingResult array]);
                }
            }else if([aKey isEqualToString:kSendMessageKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:kSendMessageKey key:kSendMessageSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }
            ///////////////////////
            [weakSelf deleteParametersForKey:aKey];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            if (operation.HTTPRequestOperation.isCancelled) {
                return ;
            }
            SNExponentialBackoff* backoff= [weakSelf.backoff objectForKey:aKey];
            if (backoff) {
                if (backoff.lastTime) {
                    [weakSelf stopBackoffForKey:aKey];
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterChats];
                    if (failure) {
                        NSError* error;
                        NSString* description = NSLocalizedString(@"app.error.no-server-connection", nil);
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                        error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoServer userInfo:userInfo];
                        failure(error);
                    }
                    [weakSelf deleteParametersForKey:aKey];
                }else{
                    if (!backoff.isStart) {
                        [backoff start];
                    }else{
                        [backoff resume];
                    }
                }
                backoff =nil;
            }else{
                backoff = [[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:@3 multiplier:2.0];
                backoff.handlertime = ^BOOL(BOOL lastTime){
                    SNExponentialBackoff* backoff=[weakSelf.backoff objectForKey:aKey];
                    [backoff pause];
                    [weakSelf loadDataForKey:aKey];
                    backoff =nil;
                    return NO;
                };
                [weakSelf.backoff setObject:backoff forKey:aKey];
                [backoff start];
            }
        }];
    }else{
        [self stopBackoffForKey:aKey];
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterChats];
        if (failure) {
            if ([[self.canSendMessageFail objectForKey:aKey] boolValue]) {
                [self.canSendMessageFail setObject:@NO forKey:aKey];
                NSError* error;
                NSString* description = NSLocalizedString(@"app.error.no-internet-connection", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoInternet userInfo:userInfo];
                failure(error);
            }
        }
    }
}


#pragma mark - Helpers
-(void)setupResponseDescriptors{
    RKResponseDescriptor* responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self chatMappingGetChat] method:RKRequestMethodPOST pathPattern:SNWSGetChats keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSSendMessage keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(RKEntityMapping*)chatMappingGetChat{
    
    RKManagedObjectStore* managedObjectStore = [[SNObjectManager sharedManager] managedObjectStore];
    
    RKEntityMapping *accountMapping = [RKEntityMapping mappingForEntityForName:@"Account" inManagedObjectStore:managedObjectStore];
    [accountMapping addAttributeMappingsFromDictionary:@{@"transmitter":@"username"}];
    [accountMapping setIdentificationAttributes:@[@"username"]];
    
    RKEntityMapping *messagesMapping = [RKEntityMapping mappingForEntityForName:@"Message" inManagedObjectStore:managedObjectStore];
    [messagesMapping addAttributeMappingsFromDictionary:[self elementToPropertyMessages]];
    [messagesMapping setIdentificationAttributes:@[@"idMessage"]];
    
    RKEntityMapping *chatMapping = [RKEntityMapping mappingForEntityForName:@"Chat" inManagedObjectStore:managedObjectStore];
    [chatMapping addAttributeMappingsFromDictionary:[self elementToPropertyChat]];
    [chatMapping setIdentificationAttributes:@[@"interlocutorUsername"]];
    
    [messagesMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"chat" withMapping:chatMapping]];
    [chatMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"interlocutor" withMapping:accountMapping]];
    
    return messagesMapping;
}
-(NSDictionary*)elementToPropertyMessages{
    return @{@"idMessage":@"idMessage",
             @"date":@"date",
             @"message":@"message"};
}

-(NSDictionary*)elementToPropertyChat{
    return @{@"transmitter":@"interlocutorUsername"};
}

-(NSDictionary*)buildParameterWithUsername:(NSString*)aUsername interlocutor:(NSString*)aInterlocutor date:(NSDate*)date {
    return @{@"fromUsername":aInterlocutor,
             @"toUsername":aUsername,
             @"date":date};
}
-(NSDictionary*)buildParameterWithMessage:(NSString*)message fromUsername:(NSString*)fromUsername toUsername:(NSString*)toUsername{
    return @{@"fromusername":fromUsername,
             @"tousername":toUsername,
             @"msg":message};
}

#pragma mark - Helpers load data
-(void)cancelRequestForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kGetChatsKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetChats];
    }
    if ([aKey isEqualToString:kSendMessageKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSSendMessage];
    }
}
-(id)parameterForMethod:(NSString*)aMethod key:(NSString*)key{
    id object = [(NSMutableDictionary*)[self.parameters objectForKey:aMethod] objectForKey:key];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}
-(void)deleteParametersForKey:(NSString*)akey{
    [self.saveParameters setObject:@NO forKey:akey];
    NSMutableDictionary* parameters = [self.parameters objectForKey:akey];
    NSMutableArray* keys = [NSMutableArray array];
    for (NSString* key in parameters) {
        [keys addObject:key];
    }
    for (int i=0; i<keys.count; i++) {
        [parameters setObject:[NSNull null] forKey:keys[i]];
    }
    keys=nil;
    parameters =nil;
}
-(NSDictionary*)buildParametersForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kGetChatsKey]) {
        return [self buildParameterWithUsername:[self parameterForMethod:kGetChatsKey key:kGetChatsUsernameParameter]interlocutor:[self parameterForMethod:kGetChatsKey key:kGetChatsInterlocutorParameter] date:[self parameterForMethod:kGetChatsKey key:kGetChatsDateParameter]];
    }else if ([aKey isEqualToString:kSendMessageKey]){
        return [self buildParameterWithMessage:[self parameterForMethod:kSendMessageKey key:kSendMessageParameter] fromUsername:[self parameterForMethod:kSendMessageKey key:kSendMessageFromUserParameter] toUsername:[self parameterForMethod:kSendMessageKey key:kSendMessageToUserParameter]];
    }else{
        return nil;
    }
}
-(NSString*)pathForKey:(NSString*)akey{
    if ([akey isEqualToString:kGetChatsKey]) {
        return SNWSGetChats;
    }else if([akey isEqualToString:kSendMessageKey]){
        return SNWSSendMessage;
    }else{
        return nil;
    }
}

-(id)verifyParameter:(id)parameter{
    if (parameter) {
        return parameter;
    }else{
        return [NSNull null];
    }
}

#pragma mark - Helpers backoff
-(void)stopBackoffForKey:(NSString*)aKey{
    SNExponentialBackoff* backoff = [self.backoff objectForKey:aKey];
    if (backoff) {
        if ([backoff isStart]) {
            [backoff stop];
        }
    }
    backoff =nil;
}

#pragma mark - Reachability
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
            [self changeState:NO];
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            [self changeState:YES];
            break;
    }
}
-(void)changeState:(BOOL)status{
    if (self.previusConnectionState!=status) {
        self.previusConnectionState = status;
        if (status) {
            [self reachableTask];
        }else{
            [self noReachableTask];
        }
    }
}
-(void)noReachableTask{
    for (NSString* key in self.inProcess) {
        if ([[self.inProcess objectForKey:key] boolValue]) {
            [self cancelRequestForKey:key];
            [self stopBackoffForKey:key];
        }else{
            [self stopBackoffForKey:key];
        }
        void(^failure)(NSError* error)=[self parameterForMethod:key key:kFailureParameterChats];
        if (failure) {
            if ([[self.canSendMessageFail objectForKey:key] boolValue]) {
                [self.canSendMessageFail setObject:@NO forKey:key];
                NSError* error;
                NSString* description = NSLocalizedString(@"app.error.no-internet-connection", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoInternet userInfo:userInfo];
                failure(error);
            }
        }
    }
}
-(void)reachableTask{
    for (NSString* key in self.saveParameters) {
        [self.canSendMessageFail setObject:@YES forKey:key];
        if([[self.saveParameters objectForKey:key] boolValue]){
            if (![[self.inProcess objectForKey:key] boolValue]) {
                [self loadDataForKey:key];
            }
        }
    }
}

@end
