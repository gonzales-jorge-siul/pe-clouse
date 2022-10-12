//
//  SNPostResourceManager.m
//  SNApp
//
//  Created by JG on 6/19/15.
//  Copyright (c) 2015 JG. All rights reserved.
// :∫
#import "SNObjectManager.h"
#import "SNPostResourceManager.h"
#import "Reachability.h"
#import "SNExponentialBackoff.h"
#import "SNConstans.h"
#import "SNDate.h"

@interface SNPostResourceManager ()
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
//Last reachability
@property(nonatomic)BOOL previousConnectionState;
@end

@implementation SNPostResourceManager
#pragma mark - constants
NSString* const SNWSGetPost= @"/getpost";
NSString* const SNWSUploadPost= @"/uploads";
NSString* const SNWBWow=@"/surprised";
NSString* const SNWSReportPost = @"/report";
NSString* const kGetPostsKey = @"GetPostsKey";
NSString* const kUploadPostKey = @"UploadPostKey";
NSString* const kWowKey = @"WowKey";
NSString* const kReportPostKey = @"ReportPostKey";
//Get posts
NSString* const kGetPostsLocationParameter =@"GetPostsLocationParameter";
NSString* const kGetPostsRadioParameter =@"GetPostsRadioParameter";
NSString* const kGetPostsDateParameter =@"GetPostsDateParameter";
NSString* const kGetPostGetOldersParameter = @"GetPostGetOldersParameter";
NSString* const kGetPostsUsernameParameter =@"GetPostsUsernameParameter";
NSString* const kGetPostsSuccessParameter =@"GetPostsSuccessParameter";
//Upload post
NSString* const kUploadPostRequestParameter = @"UploadPostPhotoPathParameter";
//NSString* const kUploadPostIdAccountParameter = @"UploadPostIdAccountParameter";
//NSString* const kUploadPostContentParameter = @"UploadPostContentParameter";
//NSString* const kUploadPostDateParameter = @"UploadPostDateParameter";
//NSString* const kUploadPostLatitudeParameter = @"UploadPostLatitudeParameter";
//NSString* const kUploadPostLongitudeParameter = @"UploadPosLongitudetParameter";
NSString* const kUploadPostSuccessParameter = @"UploadPostSuccessParameter";
//Wow
NSString* const kWowIdAccountParameter = @"WowIdAccountParameter";
NSString* const kWowIdPostParameter = @"WowIdPostParameter";
NSString* const kWowDateParameter = @"WowDateParameter";
NSString* const kWowSuccessParameter = @"WowSuccessParameter";
//Report post
NSString* const kReportPostIdAccountParameter = @"ReportPostIdAccountParameter";
NSString* const kReportPostIdParameter = @"ReportPostIdParameter";
NSString* const kReportPostIdaccountReportParameter = @"ReportPostIdAccountReportParameter";
NSString* const kReportPostDetailParameter = @"ReportPostDetailParameter";
NSString* const kReportPostSuccessParameter = @"ReportPostSuccessParameter";
//Failure
NSString* const kFailureParameterPost = @"FailureParameterPost";
//Number of repetitions
NSString* const kNumberOfRepetitionsParameterPost =@"NumberOfRepetitionsParameterPost";

#pragma mark - Life cycle
+(instancetype)sharedManager{
    static SNPostResourceManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //Initialization
        sharedManager = [[self alloc] init];
        [sharedManager setupResponseDescriptor];
        sharedManager.parameters =[[NSMutableDictionary alloc] init];
        sharedManager.saveParameters = [NSMutableDictionary dictionaryWithDictionary:@{kGetPostsKey:@NO,kUploadPostKey:@NO,kWowKey:@NO,kReportPostKey:@NO}];
        sharedManager.canSendMessageFail =[NSMutableDictionary dictionaryWithDictionary:@{kGetPostsKey:@NO,kUploadPostKey:@NO,kWowKey:@NO,kReportPostKey:@NO}];
        sharedManager.inProcess =[NSMutableDictionary dictionaryWithDictionary:@{kGetPostsKey:@NO,kUploadPostKey:@NO,kWowKey:@NO,kReportPostKey:@NO}];
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

-(void)getPostsWithLocation:(CLLocation *)location radio:(NSNumber*)radio date:(NSDate*)date username:(NSString*)username success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure maxNumberOfRepetitions:(NSNumber*)repetitions{
    NSArray* parametersArray = @[location,radio,date,username,[self verifyParameter:success],[self verifyParameter:failure],repetitions];
    NSArray* keysArray= @[kGetPostsLocationParameter,kGetPostsRadioParameter,kGetPostsDateParameter,kGetPostsUsernameParameter,kGetPostsSuccessParameter,kFailureParameterPost,kNumberOfRepetitionsParameterPost];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetPostsKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetPostsKey];
    [self.saveParameters setObject:@YES forKey:kGetPostsKey];
    [self loadDataForKey:kGetPostsKey];
}

-(void)getPostsWithLocation:(CLLocation *)location radio:(NSNumber*)radio date:(NSDate*)date username:(NSString*)username getOlders:(BOOL)getolders success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[location,radio,date,username,getolders?@(0):@(1),[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kGetPostsLocationParameter,kGetPostsRadioParameter,kGetPostsDateParameter,kGetPostsUsernameParameter,kGetPostGetOldersParameter,kGetPostsSuccessParameter,kFailureParameterPost];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetPostsKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetPostsKey];
    [self.saveParameters setObject:@YES forKey:kGetPostsKey];
    [self loadDataForKey:kGetPostsKey];
}

-(void)cancelGetPosts{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetPostsKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetPost];
        }
    }
    [self stopBackoffForKey:kGetPostsKey];
    [self deleteParametersForKey:kGetPostsKey];
}
-(void)uploadPostWithURL:(NSURL *)url withAccountId:(NSNumber*)accountID content:(NSString*)content latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude success:(void(^)(Post* post))success failure:(void(^)(NSError* error))failure {

    NSMutableURLRequest* request =[[SNObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:SNWSUploadPost parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError* error;
        if (url) {
            [formData appendPartWithFileURL:url name:@"displayImage" error:&error];
        }else{
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"displayImage"];
        }
        //Append data in this way cause that those are put in strict order
        [formData appendPartWithFormData:[[accountID description] dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
        [formData appendPartWithFormData:[content dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
        [formData appendPartWithFormData:[[latitude description] dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
        [formData appendPartWithFormData:[[longitude description] dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
    }];
    
    NSArray* parametersArray = @[request,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kUploadPostRequestParameter,kUploadPostSuccessParameter,kFailureParameterPost];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kUploadPostKey];
    [self.canSendMessageFail setObject:@YES forKey:kUploadPostKey];
    [self.saveParameters setObject:@YES forKey:kUploadPostKey];
    [self loadFormDataForKey:kUploadPostKey];
}
-(void)cancelUploadPost{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kUploadPostKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUploadPost];
        }
    }
    [self stopBackoffForKey:kUploadPostKey];
    [self deleteParametersForKey:kUploadPostKey];
}
-(void)wowPostWithIDAccount:(NSNumber*)aIdAccount idPost:(NSNumber*)aPostId date:(NSDate*)aDate success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure{
    NSArray* parametersArray = @[aIdAccount,aPostId,aDate,success,failure];
    NSArray* keysArray= @[kWowIdAccountParameter,kWowIdPostParameter,kWowDateParameter,kWowSuccessParameter,kFailureParameterPost];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kWowKey];
    [self.canSendMessageFail setObject:@YES forKey:kWowKey];
    [self.saveParameters setObject:@YES forKey:kWowKey];
    [self loadDataForKey:kWowKey];
}
-(void)cancelWow{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kWowKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWBWow];
        }
    }
    [self stopBackoffForKey:kWowKey];
    [self deleteParametersForKey:kWowKey];
}
-(void)reportPostWithIdAccount:(NSNumber *)idAccount idPost:(NSNumber *)postId idAccountReport:(NSNumber *)idAccounReport detail:(NSString *)detail success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[idAccount,postId,idAccounReport,detail,success,failure];
    NSArray* keysArray= @[kReportPostIdAccountParameter,kReportPostIdParameter,kReportPostIdaccountReportParameter,kReportPostDetailParameter,kReportPostSuccessParameter,kFailureParameterPost];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kReportPostKey];
    [self.canSendMessageFail setObject:@YES forKey:kReportPostKey];
    [self.saveParameters setObject:@YES forKey:kReportPostKey];
    [self loadDataForKey:kReportPostKey];
}
-(void)cancelReportPost{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kReportPostKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSReportPost];
        }
    }
    [self stopBackoffForKey:kReportPostKey];
    [self deleteParametersForKey:kReportPostKey];
}
#pragma mark - Private
-(void)loadDataForKey:(NSString*)aKey{
    if ([self isInternetReachable]) {
        [self.inProcess setObject:@YES forKey:aKey];
        SNPostResourceManager* __weak weakSelf = self;
        [[SNObjectManager sharedManager] postObject:nil path:[self pathForKey:aKey] parameters:[self buildParametersForKey:aKey] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
            ///////////////////////
            if ([aKey isEqualToString:kGetPostsKey]) {
                void(^success)(NSArray* response) = [weakSelf parameterForMethod:kGetPostsKey key:kGetPostsSuccessParameter];
                if (success) {
                    success([mappingResult array]);
                }
            }else if ([aKey isEqualToString:kWowKey]){
                void(^success)(ResponseServer*) = [weakSelf parameterForMethod:kWowKey key:kWowSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kReportPostKey]){
                void(^success)(ResponseServer*) = [weakSelf parameterForMethod:kReportPostKey key:kReportPostSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }
            ///////////////////////
            [weakSelf deleteParametersForKey:aKey];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            if (operation.HTTPRequestOperation.isCancelled) {
                return;
            }
            SNExponentialBackoff* backoff= [weakSelf.backoff objectForKey:aKey];
            if (backoff) {
                if (backoff.lastTime) {
                    [weakSelf stopBackoffForKey:aKey];
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterPost];
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
                backoff = [[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:[weakSelf parameterForMethod:aKey key:kNumberOfRepetitionsParameterPost]?[weakSelf parameterForMethod:aKey key:kNumberOfRepetitionsParameterPost]:@6 multiplier:2.0];
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
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterPost];
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

-(void)loadFormDataForKey:(NSString*)aKey{
 //    RKManagedObjectRequestOperation *managedOperation = [[SNObjectManager sharedManager] managedObjectRequestOperationWithRequest:[self requestParameterForMethod:aKey] managedObjectContext:[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//    }];
//    [[SNObjectManager sharedManager] enqueueObjectRequestOperation:managedOperation];
    
    if ([self isInternetReachable]) {
        [self.inProcess setObject:@YES forKey:aKey];
        SNPostResourceManager* __weak weakSelf= self;
        RKManagedObjectRequestOperation *managedOperation = [[SNObjectManager sharedManager] managedObjectRequestOperationWithRequest:[self requestParameterForMethod:aKey] managedObjectContext:[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
//////////////////////////////////////////////////////////////////////////////////////
            if ([aKey isEqualToString:kUploadPostKey]) {
                void(^success)(Post* post) = [weakSelf parameterForMethod:kUploadPostKey key:kUploadPostSuccessParameter];
                if (mappingResult.array && mappingResult.array.count>0) {
                    Post* post=(Post*)[mappingResult.array firstObject];
//                    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond
//                    ;
//                    NSCalendar *calendar = [NSCalendar currentCalendar];
//                    NSDateComponents *comps = [calendar components:unitFlags fromDate:post.date];
//                    comps.hour += 4;
//                    NSDate* date =[calendar dateFromComponents:comps];
                    post.creationDate = [SNDate serverDate];
                    post.date = [SNDate serverDate];
                    if (success) {
                        success(post);
                    }
                }
            }
//////////////////////////////////////////////////////////////////////////////////////
            [weakSelf deleteParametersForKey:aKey];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            if (operation.HTTPRequestOperation.isCancelled) {
                return;
            }
            SNExponentialBackoff* backoff= [weakSelf.backoff objectForKey:aKey];
            if (backoff) {
                if (backoff.lastTime) {
                    [weakSelf stopBackoffForKey:aKey];
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterPost];
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
                backoff = [[SNExponentialBackoff alloc] initWithMaxNumberOfRepetitions:@6 multiplier:2.0];
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
        [[SNObjectManager sharedManager] enqueueObjectRequestOperation:managedOperation];
    }else{
        [self stopBackoffForKey:aKey];
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterPost];
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
-(id)requestParameterForMethod:(NSString*)aMethod{
    if ([aMethod isEqualToString:kUploadPostKey]) {
        return [self parameterForMethod:aMethod key:kUploadPostRequestParameter];
    }else{
        return nil;
    }
}

#pragma mark - Helpers
-(void)setupResponseDescriptor{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self postsMapping] method:RKRequestMethodPOST pathPattern:SNWSGetPost keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWBWow keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSReportPost keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self uploadPostsMapping] method:RKRequestMethodPOST pathPattern:SNWSUploadPost keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(RKEntityMapping*)postsMapping{
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:[self elementToProperty]];
    
    [entityMapping setIdentificationAttributes:@[@"idPost"]];
    return entityMapping;
}

-(RKEntityMapping*)uploadPostsMapping{
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:[self elementToPropertyUpload]];
    
    [entityMapping setIdentificationAttributes:@[@"idPost"]];
    return entityMapping;
}

-(NSDictionary*)buildParametersLocation:(CLLocation*)location radio:(NSNumber*)radio date:(NSDate*)date username:(NSString*)username getOlders:(NSNumber*)getOlders{
    return @{@"lat":[NSString stringWithFormat:@"%f",location.coordinate.latitude] ,
             @"lng":[NSString stringWithFormat:@"%f",location.coordinate.longitude],
             @"radio":radio,
             @"update":date,
             @"username":username,
             @"olders":(getOlders?getOlders:@0)};
}
-(NSDictionary*)buildParametersWithIdAccount:(NSNumber*)aIdAccount idPost:(NSNumber*)aIdPost date:(NSDate*)date{
    return @{@"idAccount":aIdAccount,
             @"idPost":aIdPost,
             @"date":date};
}
-(NSDictionary*)buildParameterWithIdAccount:(NSNumber*)idAccount idPost:(NSNumber*)idPost idAccountReport:(NSNumber*)idAccountReport detail:(NSString*)detail{
    return @{@"idAccount":idAccount,
             @"idPost":idPost,
             @"idAccountReport":idAccountReport,
             @"detail":detail};
}
-(NSDictionary*)elementToProperty{
    return @{
             @"idPost":@"idPost",
             @"idLocation":@"idLocation",
             @"content":@"content",
             @"rate":@"rate",
             @"updateDate":@"date",
             @"createdDate":@"creationDate",
             @"numComment":@"numComment",
             @"photo":@"photo",
             @"lat":@"lat",
             @"lng":@"lng",
             @"distance":@"distance"};
}

-(NSDictionary*)elementToPropertyUpload{
    return @{
             @"idPost":@"idPost",
             @"idLocation":@"idLocation",
             @"content":@"content",
             @"rate":@"rate",
             @"date":@"date",
             @"createdDate":@"creationDate",
             @"numComment":@"numComment",
             @"photo":@"photo",
             @"lat":@"lat",
             @"lng":@"lng",
             @"distance":@"distance"};
}

#pragma mark - Helpers load data
-(NSString*)pathForKey:(NSString*)akey{
    if ([akey isEqualToString:kGetPostsKey]) {
        return SNWSGetPost;
    }else if ([akey isEqualToString:kWowKey]){
        return SNWBWow;
    }else if([akey isEqualToString:kUploadPostKey]){
        return SNWSUploadPost;
    }else if([akey isEqualToString:kReportPostKey]){
        return SNWSReportPost;
    }else{
        return nil;
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
    if ([aKey isEqualToString:kGetPostsKey]) {
        return [self buildParametersLocation:[self parameterForMethod:kGetPostsKey key:kGetPostsLocationParameter] radio:[self parameterForMethod:kGetPostsKey key:kGetPostsRadioParameter] date:[self parameterForMethod:kGetPostsKey key:kGetPostsDateParameter] username:[self parameterForMethod:kGetPostsKey key:kGetPostsUsernameParameter] getOlders:[self parameterForMethod:kGetPostsKey key:kGetPostGetOldersParameter]];
    }else if([aKey isEqualToString:kWowKey]){
        return [self buildParametersWithIdAccount:[self parameterForMethod:kWowKey key:kWowIdAccountParameter] idPost:[self parameterForMethod:kWowKey key:kWowIdPostParameter] date:[self parameterForMethod:kWowKey key:kWowDateParameter]];
    }else if([aKey isEqualToString:kUploadPostKey]){
        return nil;
    }else if([aKey isEqualToString:kReportPostKey]){
        return [self buildParameterWithIdAccount:[self parameterForMethod:kReportPostKey key:kReportPostIdAccountParameter] idPost:[self parameterForMethod:kReportPostKey key:kReportPostIdParameter] idAccountReport:[self parameterForMethod:kReportPostKey key:kReportPostIdaccountReportParameter] detail:[self parameterForMethod:kReportPostKey key:kReportPostDetailParameter]];
    }else{
        return nil;
    }
}
-(void)cancelRequestForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kGetPostsKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetPost];
    }
    if ([aKey isEqualToString:kWowKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWBWow];
    }
    if ([aKey isEqualToString:kUploadPostKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUploadPost];
    }
    if([aKey isEqualToString:kReportPostKey]){
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSReportPost];
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
    if (self.previousConnectionState!=status) {
        self.previousConnectionState = status;
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
        void(^failure)(NSError* error)=[self parameterForMethod:key key:kFailureParameterPost];
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
                if ([key isEqualToString:kUploadPostKey]) {
                    [self loadFormDataForKey:key];
                }else{
                    [self loadDataForKey:key];
                }
            }
        }
    }
}

-(id)verifyParameter:(id)parameter{
    if (parameter) {
        return parameter;
    }else{
        return [NSNull null];
    }
}

@end
