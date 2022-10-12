//
//  SNCommentsResourceManager.m
//  SNApp
//
//  Created by Force Close on 6/29/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNCommentsResourceManager.h"
#import "SNObjectManager.h"
#import "Reachability.h"
#import "SNExponentialBackoff.h"
#import "SNConstans.h"
#import <malloc/malloc.h>

@interface TemporalComment : NSObject

@property(nonatomic,strong)NSNumber* idComment;

@end

@implementation TemporalComment

@end


@interface SNCommentsResourceManager ()
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

@implementation SNCommentsResourceManager
#pragma mark - Constants
NSString* const SNWSGetComments=@"/comments";
NSString* const SNWSComment=@"/comment";
NSString* const SNWSReloadComments=@"/lastComments";
NSString* const kGetCommentsKey=@"GetCommentsKey";
NSString* const kCommentKey=@"CommentKey";
NSString* const kReloadCommentsKey=@"ReloadCommentsKey";
//Get comment
NSString* const kGetCommentPostIdParameter = @"GetCommentPostIdParameter";
NSString* const kGetCommentSuccessParameter = @"GetCommentSuccessParameter";
//Comment
NSString* const kCommentContentParameter=@"CommentContentParameter";
NSString* const kCommentUsernameParameter=@"CommentUsernameParameter";
NSString* const kCommentIdPostParameter=@"CommentIdPostParameter";
NSString* const kCommentSuccessParameter = @"CommentSuccessParameter";
//Reload comments
NSString* const kReloadCommentsPostIdParameter = @"ReloadCommentsPostIdParameter";
NSString* const kReloadCommentsDateParameter = @"ReloadCommentsDateParameter";
NSString* const kReloadCommentsSuccesParameter = @"ReloadCommentsSuccessParameter";
//Failure parameter
NSString* const kFailureParameterComments = @"FailureParameterComments";

#pragma mark - Life cycle
+(instancetype)sharedManager{
    static SNCommentsResourceManager* sharedManager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //Initialization
        sharedManager = [[self alloc] init];
        [sharedManager setupResponseDescriptors];
        sharedManager.parameters =[[NSMutableDictionary alloc] init];
        sharedManager.saveParameters = [NSMutableDictionary dictionaryWithDictionary:@{kGetCommentsKey:@NO,kCommentKey:@NO,kReloadCommentsKey:@NO}];
        sharedManager.canSendMessageFail = [NSMutableDictionary dictionaryWithDictionary:@{kGetCommentsKey:@NO,kCommentKey:@NO,kReloadCommentsKey:@NO}];
        sharedManager.inProcess =[NSMutableDictionary dictionaryWithDictionary:@{kGetCommentsKey:@NO,kCommentKey:@NO,kReloadCommentsKey:@NO}];
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
-(void)getCommentsWithPostId:(NSNumber *)aPostId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[aPostId?aPostId:[NSNull null],success,failure];
    NSArray* keysArray= @[kGetCommentPostIdParameter,kGetCommentSuccessParameter,kFailureParameterComments];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetCommentsKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetCommentsKey];
    [self.saveParameters setObject:@YES forKey:kGetCommentsKey];
    NSLog(@"%@ %@",@"sve parameter yes",kGetCommentsKey);
    [self loadDataForKey:kGetCommentsKey];
}
-(void)cancelGetComments{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetCommentsKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetComments];
                 NSLog(@"%@ %@",@"cancel requesrt ",SNWSGetComments);
        }
        [self stopBackoffForKey:kGetCommentsKey];
        [self deleteParametersForKey:kGetCommentsKey];
    }else{
        [self stopBackoffForKey:kGetCommentsKey];
        [self deleteParametersForKey:kGetCommentsKey];
    }
}
-(void)commentWhitContent:(NSString *)aContent username:(NSString *)aUsername idPost:(NSNumber *)aIdPost success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray =@[aContent,aUsername,aIdPost,success,failure];
    NSArray* keysArray=@[kCommentContentParameter,kCommentUsernameParameter,kCommentIdPostParameter,kCommentSuccessParameter,kFailureParameterComments];
    NSMutableDictionary* parameters= [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kCommentKey];
    [self.canSendMessageFail setObject:@YES forKey:kCommentKey];
    [self.saveParameters setObject:@YES forKey:kCommentKey];
    NSLog(@"%@ %@",@"sve parameter yes",kCommentKey);
    [self loadDataForKey:kCommentKey];
}
-(void)cancelComment{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kCommentKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSComment];
             NSLog(@"%@ %@",@"cancel requesrt ",SNWSComment);
        }
        [self stopBackoffForKey:kCommentKey];
        [self deleteParametersForKey:kCommentKey];
    }else{
        [self stopBackoffForKey:kCommentKey];
        [self deleteParametersForKey:kCommentKey];
    }
}
-(void)reloadComments:(NSNumber *)aPostID date:(NSDate *)aDate success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray =@[aPostID,aDate,success,failure];
    NSArray* keysArray=@[kReloadCommentsPostIdParameter,kReloadCommentsDateParameter,kReloadCommentsSuccesParameter,kFailureParameterComments];
    NSMutableDictionary* parameters= [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kReloadCommentsKey];
    [self.canSendMessageFail setObject:@YES forKey:kReloadCommentsKey];
    [self.saveParameters setObject:@YES forKey:kReloadCommentsKey];
    NSLog(@"%@ %@",@"sve parameter yes",kReloadCommentsKey);
    [self loadDataForKey:kReloadCommentsKey];
}
-(void)cancelReloadComments{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kReloadCommentsKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSReloadComments];
            NSLog(@"%@ %@",@"cancel requesrt ",SNWSReloadComments);
        }
    }
    [self stopBackoffForKey:kReloadCommentsKey];
    [self deleteParametersForKey:kReloadCommentsKey];
}
#pragma mark - Private
-(void)loadDataForKey:(NSString*)aKey{
    if ([self isInternetReachable]) {
         NSLog(@"%@ %@",@"in process yes ",aKey);
        [self.inProcess setObject:@YES forKey:aKey];
        SNCommentsResourceManager* __weak weakSelf = self;
        NSString* path = [self pathForKey:aKey];
        NSDictionary* parameters = [self buildParametersForKey:aKey];
    [[SNObjectManager sharedManager] postObject:nil path:path parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         NSLog(@"%@ %@",@"in process no ",aKey);
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
        ///////////////////////
        if ([aKey isEqualToString:kGetCommentsKey]) {
            void(^success)(NSArray* response) = [weakSelf parameterForMethod:kGetCommentsKey key:kGetCommentSuccessParameter];
            if (success) {
                success([mappingResult array]);
            }
        }else if ([aKey isEqualToString:kCommentKey]){
            void(^success)(NSNumber* idComment) = [weakSelf parameterForMethod:kCommentKey key:kCommentSuccessParameter];
            if (success) {
                success([(TemporalComment*)[[mappingResult array] firstObject] idComment]);
            }
        }else if ([aKey isEqualToString:kReloadCommentsKey]){
            void(^success)(NSArray* response) = [weakSelf parameterForMethod:kReloadCommentsKey key:kReloadCommentsSuccesParameter];
            if (success) {
                success([mappingResult array]);
            }
        }
        ///////////////////////
        [weakSelf deleteParametersForKey:aKey];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            NSLog(@"%@ %@",@"in process no ",aKey);
            if (operation.HTTPRequestOperation.isCancelled) {
                 NSLog(@"%@ %@",@"cancelled ",aKey);
                return ;
            }
            SNExponentialBackoff* backoff= [weakSelf.backoff objectForKey:aKey];
            if (backoff) {
                if (backoff.lastTime) {
                    [weakSelf stopBackoffForKey:aKey];
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterComments];
                    if (failure) {
                        NSLog(@"%@ %@",@"error server",aKey);
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
                        NSLog(@"%@ %@",@"start BO",aKey);
                    }else{
                        [backoff resume];
                        NSLog(@"%@ %@",@"resume BO",aKey);
                    }
                }
                backoff =nil;
            }else{
                NSLog(@"%@ %@",@"init bo ",aKey);
                backoff = [[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:@6 multiplier:2.0];
                backoff.handlertime = ^BOOL(BOOL lastTime){
                    NSLog(@"%@ %@",@"pause bo",aKey);
                    SNExponentialBackoff* backoff=[weakSelf.backoff objectForKey:aKey];
                    [backoff pause];
                    [weakSelf loadDataForKey:aKey];
                    backoff =nil;
                    return NO;
                };
                [weakSelf.backoff setObject:backoff forKey:aKey];
                NSLog(@"%@ %@",@"start BO",aKey);
                [backoff start];
            }
        }];
    }else{
        [self stopBackoffForKey:aKey];
        NSLog(@"%@ %@",@"Try failure no internet",aKey);
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterComments];
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
    RKResponseDescriptor* responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self commentMappingGetComment] method:RKRequestMethodPOST pathPattern:SNWSGetComments keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self commentMappingComment] method:RKRequestMethodPOST pathPattern:SNWSComment keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor= [RKResponseDescriptor responseDescriptorWithMapping:[self commentMappingGetComment] method:RKRequestMethodPOST pathPattern:SNWSReloadComments keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
}

-(RKEntityMapping*)commentMappingGetComment{
    RKEntityMapping *accountMapping = [RKEntityMapping mappingForEntityForName:@"Account" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    [accountMapping addAttributeMappingsFromDictionary:@{@"username":@"username",@"name":@"name",@"birth":@"birth",@"photo":@"photo",@"status":@"status"}];
    [accountMapping setIdentificationAttributes:@[@"username"]];
    
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:[self elementToPropertyGetComment]];
    [entityMapping setIdentificationAttributes:@[@"idComment"]];
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil toKeyPath:@"account" withMapping:accountMapping]];
    return entityMapping;
}
-(RKObjectMapping*)commentMappingComment{
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[TemporalComment class]];
    [mapping addAttributeMappingsFromDictionary:[self elementToPropertyComment]];
    
    //RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    //[entityMapping addAttributeMappingsFromDictionary:[self elementToPropertyComment]];
    //[entityMapping setIdentificationAttributes:@[@"idComment"]];
    return mapping;
}
-(NSDictionary*)elementToPropertyGetComment{
    return @{
             @"idComment":@"idComment",
             @"content":@"content",
             @"date":@"date"};
}
-(NSDictionary*)elementToPropertyComment{
    return @{
             @"idComment":@"idComment"};
}
-(NSDictionary*)buildParameterWithPostId:(NSNumber*)aPostId{
    return @{@"idPost":aPostId};
}
-(NSDictionary*)buildParameterWithIdAccount:(NSNumber*)aIdAccount idPost:(NSNumber*)aIdPost content:(NSString*)aContent {
    return @{@"idAccount":aIdAccount,
             @"idPost":aIdPost,
             @"content":aContent};
}
-(NSDictionary*)buildParameterWithPostId:(NSNumber*)aPostId date:(NSDate*)aDate{
    return @{@"idPost":aPostId,
             @"date":aDate};
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
            [self changeState:NO];
            NSLog(@"%@ ",@"no reachcable");
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            [self changeState:YES];
            NSLog(@"%@ ",@"reachable");
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
        void(^failure)(NSError* error)=[self parameterForMethod:key key:kFailureParameterComments];
        if (failure) {
            if ([[self.canSendMessageFail objectForKey:key] boolValue]) {
                [self.canSendMessageFail setObject:@NO forKey:key];
                NSError* error;
                NSString* description = NSLocalizedString(@"app.error.no-internet-connection", nil);
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:description};
                error =[[NSError alloc] initWithDomain:SNSERVICES_ERROR_DOMAIN code:SNNoInternet userInfo:userInfo];
                failure(error);
                NSLog(@"%@ %@",@"send message FAilure",key);
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
                NSLog(@"%@ %@",@"Load data task reachable",key);
            }
        }
    }
}
-(void)stopBackoffForKey:(NSString*)aKey{
    SNExponentialBackoff* backoff = [self.backoff objectForKey:aKey];
    if (backoff) {
        if ([backoff isStart]) {
            [backoff stop];
        }
    }
    backoff =nil;
}
-(void)cancelRequestForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kGetCommentsKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetComments];
            NSLog(@"%@ %@",@"cancel Request",aKey);
    }
    if ([aKey isEqualToString:kCommentKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSComment];
        NSLog(@"%@ %@",@"cancel Request",aKey);
    }
    if ([aKey isEqualToString:kReloadCommentsKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSReloadComments];
        NSLog(@"%@ %@",@"cancel Request",aKey);
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
        NSLog(@"%@ %@",@"Delete parameters:",akey);
    [self.saveParameters setObject:@NO forKey:akey];
    NSMutableDictionary* parameters = [self.parameters objectForKey:akey];
    NSMutableArray* keys = [NSMutableArray array];
    for (NSString* key in parameters) {
        [keys addObject:key];
    }
    [parameters removeObjectsForKeys:keys];
//    
//    for (int i=0; i<keys.count; i++) {
//        [parameters setObject:[NSNull null] forKey:keys[i]];
//    }
    keys=nil;
    parameters =nil;
}
-(NSDictionary*)buildParametersForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kGetCommentsKey]) {
        return [self buildParameterWithPostId:[self parameterForMethod:kGetCommentsKey key:kGetCommentPostIdParameter]];
    }else if([aKey isEqualToString:kCommentKey]){
        return [self buildParameterWithIdAccount:[self parameterForMethod:kCommentKey key:kCommentUsernameParameter] idPost:[self parameterForMethod:kCommentKey key:kCommentIdPostParameter] content:[self parameterForMethod:kCommentKey key:kCommentContentParameter]];
    }else if([aKey isEqualToString:kReloadCommentsKey]){
        return [self buildParameterWithPostId:[self parameterForMethod:kReloadCommentsKey key:kReloadCommentsPostIdParameter] date:[self parameterForMethod:kReloadCommentsKey key:kReloadCommentsDateParameter]];
    }else{
        return nil;
    }
}
-(NSString*)pathForKey:(NSString*)akey{
    if ([akey isEqualToString:kGetCommentsKey]) {
        return SNWSGetComments;
    }else if ([akey isEqualToString:kCommentKey]){
        return SNWSComment;
    }else if([akey isEqualToString:kReloadCommentsKey]){
        return SNWSReloadComments;
    }else{
        return nil;
    }
}
@end

