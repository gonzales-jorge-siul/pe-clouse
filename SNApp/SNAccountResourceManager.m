//
//  SNAccountResourceManager.m
//  SNApp
//
//  Created by Force Close on 6/16/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNAccountResourceManager.h"
#import "SNObjectManager.h"
#import "Account.h"
#import "Reachability.h"
#import "SNExponentialBackoff.h"
#import "SNConstans.h"
#import "Preferences.h"

@interface SNAccountResourceManager ()
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

@implementation SNAccountResourceManager
#pragma mark - constants
NSString* const SNWSLoginService= @"/login";
NSString* const SNWSSearchService= @"/searchable";
NSString* const SNWSUpdateCloudId = @"/updateToken";
NSString* const SNWSVerifyStateAccount = @"/state";
NSString* const SNWSLoginExistService= @"/wlogin";
NSString* const SNWSGetAccount = @"/getUser";
NSString* const SNWSUpdateAccount = @"/updateUserData";
NSString* const SNWSLoginGuest =@"/guest";
NSString* const SNWSLastConnection =@"/connection";
NSString* const SNWSGetLastConnection =@"/getLastConnection";
NSString* const SNWSValidateUsername = @"/validateUser";
NSString* const SNWSGetServerDate = @"/getServerDateForIos";

NSString* const kLoginKey = @"LoginKey";
NSString* const kSearchKey = @"SearchKey";
NSString* const kUpdateCloudIdKey = @"UpdateCloudId";
NSString* const kVerifyStateAccountKey = @"VerifyStateAccountId";
NSString* const kLoginExistKey = @"LoginExistKey";
NSString* const kGetAccountKey =@"GetAccountKey";
NSString* const kUpdateAccountKey =@"UpdateAccountKey";
NSString* const kLoginGuestKey =@"LoginGuestKey";
NSString* const kLastConnectionKey =@"LastConnectionKey";
NSString* const kGetLastConnectionKey =@"GetLastConnectionKey";
NSString* const kValidateUsernameKey = @"ValidateUsernameKey";
NSString* const kGetServerDateKey =@"GetServerDateKey";

//Login
NSString* const kLoginNameParameter=@"LoginNameParameter";
NSString* const kLoginUsernameParameter =@"LoginUsernameParameter";
NSString* const kLoginPhoneParameter=@"LoginPhoneParameter";
NSString* const kLoginCloudIdParameter=@"LoginCloudIdParameter";
NSString* const kLoginIdAccountParameter =@"LoginIdAccountParameter";
NSString* const kLoginSuccessParameter=@"LoginSuccessParameter";
//Login exists (retrieve data)
NSString* const kLoginExistPhoneParameter=@"LoginExistPhoneParameter";
NSString* const kLoginExistCloudIdParameter=@"LoginExistCloudIdParameter";
NSString* const kLoginExistIdAccountParameter=@"LoginExistIdAccountParameter";
NSString* const kLoginExistSuccessParameter=@"LoginExistSuccessParameter";
//Search
NSString* const kSearchUsernameParameter = @"SearchUsernameParameter";
NSString* const kSearchSuccessParameter = @"SearchSuccessParameter";

//Update cloudId
NSString* const kUpdateCloudIdParameter = @"UpdateCloudIdParameter";
NSString* const kUpdateCloudIdUsernameParameter =@"UpdateCloudIdUsernameParameter";
NSString* const kUpdateCloudIdSuccessParameter = @"UpdateCloudIdSuccessParameter";
//Verify state account
NSString* const kVerifyStateAccountIdParameter = @"VerifyStateAccountIdParameter";
NSString* const kVerifyStateAccountSuccessParameter = @"VerifyStateAccountSuccessParameter";
//Get account
NSString* const kGetAccountUsernameParameter =@"GetAccountUsernameParameter";
NSString* const kGetAccountSuccessParameter =@"GetAccountSuccessParameter";
//Update account
NSString* const kUpdateAccountRequestParameter =@"UpdateAccountRequestParameter";
NSString* const kUpdateAccountSuccessParameter =@"UpdateAccountSuccessParameter";
//Login as guest
NSString* const kLoginGuestUsernameParameter =@"LoginGuestUsernameParameter";
NSString* const kLoginGuestCloudIdParameter =@"LoginGuestCloudIdParameter";
NSString* const kLoginGuestSuccessParameter =@"LoginGuestSuccessParameter";
//Last connection
NSString* const kLastConnectionDateParameter =@"LastConnectionDateParameter";
NSString* const kLastConnectionUsernameParameter =@"LastConnectionUsernameParameter";
NSString* const kLastConnectionIsConnectParameter =@"LastConnectionIsConnectParameter";
NSString* const kLastConnectionSuccessParameter =@"LastConnectionSuccessParameter";
//Get last connection
NSString* const kGetLastConnectionUsernameParameter =@"GetLastConnectionUsernameParameter";
NSString* const kGetLastConnectionSuccessParameter =@"GetLastConnectionSuccessParameter";
//Validate username
NSString* const kValidateUsernameParameter = @"ValidateUsernameParameter";
NSString* const kValidateUsernameSuccessParameter = @"ValidateUsernameSuccessParameter";
//Get Server Date
NSString* const kGetServerDateSuccessParameter = @"GetServerDateSuccessParameter";
//Failure
NSString* const kFailureParameterAccount = @"FailureParameter";

#pragma mark - Life cycle
+(instancetype)sharedManager{
    static SNAccountResourceManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        //Initialization
        sharedManager = [[self alloc] init];
        [sharedManager setupResponseDescriptor];
        sharedManager.parameters =[[NSMutableDictionary alloc] init];
        sharedManager.saveParameters = [NSMutableDictionary dictionaryWithDictionary:@{kLoginKey:@NO,kSearchKey:@NO,kUpdateCloudIdKey:@NO,kVerifyStateAccountKey:@NO,kLoginExistKey:@NO,kGetAccountKey:@NO,kUpdateAccountKey:@NO,kLoginGuestKey:@NO,kValidateUsernameKey:@NO,kGetServerDateKey:@NO }];
        sharedManager.canSendMessageFail =[NSMutableDictionary dictionaryWithDictionary:@{kLoginKey:@NO,kSearchKey:@NO,kUpdateCloudIdKey:@NO,kVerifyStateAccountKey:@NO,kLoginExistKey:@NO,kGetAccountKey:@NO,kUpdateAccountKey:@NO,kLoginGuestKey:@NO,kValidateUsernameKey:@NO, kGetServerDateKey:@NO}];
        sharedManager.inProcess =[NSMutableDictionary dictionaryWithDictionary:@{kLoginKey:@NO,kSearchKey:@NO,kUpdateCloudIdKey:@NO,kVerifyStateAccountKey:@NO,kLoginExistKey:@NO,kGetAccountKey:@NO,kUpdateAccountKey:@NO,kLoginGuestKey:@NO,kValidateUsernameKey:@NO, kGetServerDateKey:@NO}];
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
-(void)loginWithName:(NSString *)name username:(NSString*)username cloudId:(NSString *)cloudId phoneNumber:(NSString *)phoneNumber idAccount:(NSNumber*)idAccount success:(void (^)(Account *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[name,username,cloudId,phoneNumber,idAccount,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kLoginNameParameter,kLoginUsernameParameter,kLoginCloudIdParameter,kLoginPhoneParameter,kLoginIdAccountParameter,kLoginSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kLoginKey];
    [self.canSendMessageFail setObject:@YES forKey:kLoginKey];
    [self.saveParameters setObject:@YES forKey:kLoginKey];
    [self loadDataForKey:kLoginKey];
}
-(void)loginWithPhone:(NSString *)phone cloudId:(NSString *)cloudId idAccount:(NSNumber*)idAccount success:(void (^)(Account *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[phone,cloudId,idAccount,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kLoginExistPhoneParameter,kLoginExistCloudIdParameter,kLoginExistIdAccountParameter,kLoginExistSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kLoginExistKey];
    [self.canSendMessageFail setObject:@YES forKey:kLoginExistKey];
    [self.saveParameters setObject:@YES forKey:kLoginExistKey];
    [self loadDataForKey:kLoginExistKey];
}
-(void)cancelLogin{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kLoginKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginService];
        }
        if ([[self.inProcess objectForKey:kLoginExistKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginExistService];
        }
    }
    [self stopBackoffForKey:kLoginExistKey];
    [self deleteParametersForKey:kLoginExistKey];
    
    [self stopBackoffForKey:kLoginKey];
    [self deleteParametersForKey:kLoginKey];
}
-(void)search:(NSString *)name success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[name,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kSearchUsernameParameter,kSearchSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kSearchKey];
    [self.canSendMessageFail setObject:@YES forKey:kSearchKey];
    [self.saveParameters setObject:@YES forKey:kSearchKey];
    [self loadDataForKey:kSearchKey];
}
-(void)cancelSearch{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kSearchKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSSearchService];
        }
    }
    [self stopBackoffForKey:kSearchKey];
    [self deleteParametersForKey:kSearchKey];
}

-(void)updateCloudId:(NSString *)cloudId username:(NSString *)username success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[cloudId,username,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kUpdateCloudIdParameter, kUpdateCloudIdUsernameParameter,kUpdateCloudIdSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kUpdateCloudIdKey];
    [self.canSendMessageFail setObject:@YES forKey:kUpdateCloudIdKey];
    [self.saveParameters setObject:@YES forKey:kUpdateCloudIdKey];
    [self loadDataForKey:kUpdateCloudIdKey];
}
-(void)cancelUpdateCloudId{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kUpdateCloudIdKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUpdateCloudId];
        }
    }
    [self stopBackoffForKey:kUpdateCloudIdKey];
    [self deleteParametersForKey:kUpdateCloudIdKey];
}
-(void)verifyStateAccount:(NSNumber *)accountId success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[accountId,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kVerifyStateAccountIdParameter,kVerifyStateAccountSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kVerifyStateAccountKey];
    [self.canSendMessageFail setObject:@YES forKey:kVerifyStateAccountKey];
    [self.saveParameters setObject:@YES forKey:kVerifyStateAccountKey];
    [self loadDataForKey:kVerifyStateAccountKey];
}
-(void)cancelVerifyStateAccount{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kVerifyStateAccountKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSVerifyStateAccount];
        }
    }
    [self stopBackoffForKey:kVerifyStateAccountKey];
    [self deleteParametersForKey:kVerifyStateAccountKey];
}
-(void)getAccount:(NSString *)username success:(void (^)(Account *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[username,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kGetAccountUsernameParameter,kGetAccountSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetAccountKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetAccountKey];
    [self.saveParameters setObject:@YES forKey:kGetAccountKey];
    [self loadDataForKey:kGetAccountKey];
}
-(void)cancelGetAccount{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetAccountKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetAccount];
        }
    }
    [self stopBackoffForKey:kGetAccountKey];
    [self deleteParametersForKey:kGetAccountKey];
}
-(void)updateAccountName:(NSString *)name status:(NSString *)status birth:(NSDate *)birth likes:(NSString *)likes photo:(NSURL *)photoURL username:(NSString *)username success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    
        NSMutableURLRequest* request =[[SNObjectManager sharedManager] multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:SNWSUpdateAccount parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError* error;
            if (photoURL) {
                [formData appendPartWithFileURL:photoURL name:@"displayImage" error:&error];
            }
            //Append data in this way cause that those are put in strict order
            [formData appendPartWithFormData:[username dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
            [formData appendPartWithFormData:[name dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
            [formData appendPartWithFormData:[status dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
            [formData appendPartWithFormData:[[birth description] dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
            [formData appendPartWithFormData:[likes dataUsingEncoding:NSUTF8StringEncoding] name:@"dataPost"];
        }];
    
    NSArray* parametersArray = @[request,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kUpdateAccountRequestParameter,kUpdateAccountSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kUpdateAccountKey];
    [self.canSendMessageFail setObject:@YES forKey:kUpdateAccountKey];
    [self.saveParameters setObject:@YES forKey:kUpdateAccountKey];
    [self loadFormDataForKey:kUpdateAccountKey];
}
-(void)cancelUpdateAccount{
    [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUpdateAccount];
}

-(void)loginAsGuest:(NSString *)username cloudId:(NSString *)cloudId success:(void (^)(Account *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[username,cloudId,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kLoginGuestUsernameParameter,kLoginGuestCloudIdParameter,kLoginGuestSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kLoginGuestKey];
    [self.canSendMessageFail setObject:@YES forKey:kLoginGuestKey];
    [self.saveParameters setObject:@YES forKey:kLoginGuestKey];
    [self loadDataForKey:kLoginGuestKey];
}
-(void)cancelLoginAsGuest{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kLoginGuestKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginGuest];
        }
    }
    [self stopBackoffForKey:kLoginGuestKey];
    [self deleteParametersForKey:kLoginGuestKey];
}

-(void)lastConnection:(NSDate *)date username:(NSString *)username isConnect:(NSNumber*)isConnect success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[date,username,isConnect,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kLastConnectionDateParameter,kLastConnectionUsernameParameter,kLastConnectionIsConnectParameter,kLastConnectionSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kLastConnectionKey];
    [self.canSendMessageFail setObject:@YES forKey:kLastConnectionKey];
    [self.saveParameters setObject:@YES forKey:kLastConnectionKey];
    [self loadDataForKey:kLastConnectionKey];
}
-(void)cancelLastConnection{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kLastConnectionKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLastConnection];
        }
    }
    [self stopBackoffForKey:kLastConnectionKey];
    [self deleteParametersForKey:kLastConnectionKey];
}
-(void)getLastConnectionFor:(NSString *)username success:(void (^)(UserLastConnection *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[username,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kGetLastConnectionUsernameParameter,kGetLastConnectionSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetLastConnectionKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetLastConnectionKey];
    [self.saveParameters setObject:@YES forKey:kGetLastConnectionKey];
    [self loadDataForKey:kGetLastConnectionKey];
}
-(void)cancelGetLastConnection{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetLastConnectionKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetLastConnection];
        }
    }
    [self stopBackoffForKey:kGetLastConnectionKey];
    [self deleteParametersForKey:kGetLastConnectionKey];
}
-(void)validateUsername:(NSString *)username success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure{
    NSArray* parametersArray = @[username,[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kValidateUsernameParameter,kValidateUsernameSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kValidateUsernameKey];
    [self.canSendMessageFail setObject:@YES forKey:kValidateUsernameKey];
    [self.saveParameters setObject:@YES forKey:kValidateUsernameKey];
    [self loadDataForKey:kValidateUsernameKey];
}
-(void)cancelValidateUsername{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kValidateUsernameKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSValidateUsername];
        }
    }
    [self stopBackoffForKey:kValidateUsernameKey];
    [self deleteParametersForKey:kValidateUsernameKey];
}
-(void)getServerDateWithBlockOnSuccess:(void(^)(SNServer* response))success failure:(void(^)(NSError* error))failure{
    NSArray* parametersArray = @[[self verifyParameter:success],[self verifyParameter:failure]];
    NSArray* keysArray= @[kGetServerDateSuccessParameter,kFailureParameterAccount];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjects:parametersArray forKeys:keysArray];
    [self.parameters setObject:parameters forKey:kGetServerDateKey];
    [self.canSendMessageFail setObject:@YES forKey:kGetServerDateKey];
    [self.saveParameters setObject:@YES forKey:kGetServerDateKey];
    [self loadDataForKey:kGetServerDateKey];
}
-(void)cancelGetServerDate{
    if ([self isInternetReachable]) {
        if ([[self.inProcess objectForKey:kGetServerDateKey] boolValue]) {
            [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetServerDate];
        }
    }
    [self stopBackoffForKey:kGetServerDateKey];
    [self deleteParametersForKey:kGetServerDateKey];
}
#pragma mark - Private
-(void)loadDataForKey:(NSString*)aKey{
    if ([self isInternetReachable]) {
        [self.inProcess setObject:@YES forKey:aKey];
        SNAccountResourceManager* __weak weakSelf= self;
        [[SNObjectManager sharedManager] postObject:nil path:[self pathForKey:aKey] parameters:[self buildParametersForKey:aKey] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
            ///////////////////////
            if ([aKey isEqualToString:kLoginKey]) {
                void(^success)(Account* account) = [weakSelf parameterForMethod:kLoginKey key:kLoginSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kSearchKey]){
                void(^success)(NSArray* response) = [weakSelf parameterForMethod:kSearchKey key:kSearchSuccessParameter];
                if (success) {
                    success([mappingResult array]);
                }
            }else if ([aKey isEqualToString:kUpdateCloudIdKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:kUpdateCloudIdKey key:kUpdateCloudIdSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kVerifyStateAccountKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:kVerifyStateAccountKey key:kVerifyStateAccountSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kLoginExistKey]){
                void(^success)(Account* account) = [weakSelf parameterForMethod:kLoginExistKey key:kLoginExistSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kGetAccountKey]){
                void(^success)(Account* account) = [weakSelf parameterForMethod:kGetAccountKey key:kGetAccountSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kLoginGuestKey]){
                void(^success)(Account* account) = [weakSelf parameterForMethod:kLoginGuestKey key:kLoginGuestSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kLastConnectionKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:kLastConnectionKey key:kLastConnectionSuccessParameter];
                if (success) {
                    id object = [[mappingResult array] firstObject];
                    if (object) {
                        success(object);
                    }
                }
            }else if ([aKey isEqualToString:kGetLastConnectionKey]){
                void(^success)(UserLastConnection* response) = [weakSelf parameterForMethod:kGetLastConnectionKey key:kGetLastConnectionSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kValidateUsernameKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:kValidateUsernameKey key:kValidateUsernameSuccessParameter];
                if (success) {
                    NSLog(@"%@",[(ResponseServer*)[mappingResult.array firstObject] response]);
                    NSLog(@"results: %lu",(unsigned long)[[mappingResult array] count]);
                    NSLog(@"first object: %@",[[mappingResult array] firstObject]);
                    success([[mappingResult array] firstObject]);
                }
            }else if ([aKey isEqualToString:kGetServerDateKey]){
                void(^success)(SNServer* response) = [weakSelf parameterForMethod:kGetServerDateKey key:kGetServerDateSuccessParameter];
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
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterAccount];
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
    }else{
        [self stopBackoffForKey:aKey];
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterAccount];
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
    if ([self isInternetReachable]) {
        [self.inProcess setObject:@YES forKey:aKey];
        SNAccountResourceManager* __weak weakSelf = self;
        RKManagedObjectRequestOperation *managedOperation = [[SNObjectManager sharedManager] managedObjectRequestOperationWithRequest:[self requestParameterForMethod:aKey] managedObjectContext:[[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [weakSelf.inProcess setObject:@NO forKey:aKey];
            [weakSelf stopBackoffForKey:aKey];
//////////////////////////////////////////////////////////
            if([aKey isEqualToString:kUpdateAccountKey]){
                void(^success)(ResponseServer* response) = [weakSelf parameterForMethod:aKey key:kUpdateAccountSuccessParameter];
                if (success) {
                    success([[mappingResult array] firstObject]);
                }
            }
//////////////////////////////////////////////////////////
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
                    void(^failure)(NSError* error)=[weakSelf parameterForMethod:aKey key:kFailureParameterAccount];
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
        void(^failure)(NSError* error)=[self parameterForMethod:aKey key:kFailureParameterAccount];
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
    if ([aMethod isEqualToString:kUpdateAccountKey]) {
        return [self parameterForMethod:aMethod key:kUpdateAccountRequestParameter];
    }else{
        return nil;
    }
}

#pragma mark - Helpers
-(void)setupResponseDescriptor{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self accountMapping] method:RKRequestMethodPOST pathPattern:SNWSLoginService keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self accountMapping] method:RKRequestMethodPOST pathPattern:SNWSSearchService keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSUpdateCloudId keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSVerifyStateAccount keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self accountMapping] method:RKRequestMethodPOST pathPattern:SNWSLoginExistService keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self accountMapping] method:RKRequestMethodPOST pathPattern:SNWSGetAccount keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSUpdateAccount keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self accountMapping] method:RKRequestMethodPOST pathPattern:SNWSLoginGuest keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSLastConnection keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[UserLastConnection userLastConnectionMapping] method:RKRequestMethodPOST pathPattern:SNWSGetLastConnection keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResponseServer responseServerMapping] method:RKRequestMethodPOST pathPattern:SNWSValidateUsername keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[SNServer serverMapping] method:RKRequestMethodPOST pathPattern:SNWSGetServerDate keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[SNObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}
-(RKEntityMapping*)accountMapping{
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Account" inManagedObjectStore:[[SNObjectManager sharedManager] managedObjectStore]];
    [entityMapping addAttributeMappingsFromDictionary:[self elementToProperty]];
    [entityMapping setIdentificationAttributes:@[@"username"]];
    return entityMapping;
}
-(NSDictionary*)elementToProperty{
    return @{
             @"idAccount":@"idAccount",
             @"username":@"username",
             @"name":@"name",
             @"birth":@"birth",
             @"photo":@"photo",
             @"status":@"status",
             @"state":@"state",
             @"interests":@"likes"};
}
-(NSDictionary*)buildParametersWithName:(NSString*)name username:(NSString*)username cloudId:(NSString*)cloudId phoneNumber:(NSString*)phoneNumber idAccount:(NSNumber*)idAccount{
    return @{@"name":name,
             @"username":username,
             @"cloudId":cloudId,
             @"phone":phoneNumber,
             @"idAccount":idAccount};
}
-(NSDictionary*)buildParameterWithCloudId:(NSString*)cloudID username:(NSString*)username{
    return @{@"username":username,
             @"cloudId":cloudID};
}
-(NSDictionary*)buildParameterWithAccountId:(NSString*)accountID{
    return @{@"idAccount":accountID};
}
-(NSDictionary*)buildParameterWithPhone:(NSString*)phone cloudId:(NSString*)cloudID idAccount:(NSNumber*)idAccount{
    return @{@"phone":phone,
             @"cloudId":cloudID,
             @"idAccount":idAccount};
}
-(NSDictionary*)buildParameterWithUsername:(NSString*)username{
    return @{@"username":username};
}
-(NSDictionary*)buildParameterWithDate:(NSDate*)date username:(NSString*)username isConnect:(NSNumber*)isConnect{
        return @{@"isConnect":isConnect,
                 @"username":username};
}

#pragma mark - Helpers load data
-(NSString*)pathForKey:(NSString*)akey{
    if ([akey isEqualToString:kLoginKey]) {
        return SNWSLoginService;
    }else if ([akey isEqualToString:kSearchKey]){
        return SNWSSearchService;
    }else if ([akey isEqualToString:kUpdateCloudIdKey]){
        return SNWSUpdateCloudId;
    }else if ([akey isEqualToString:kVerifyStateAccountKey]){
        return SNWSVerifyStateAccount;
    }else if([akey isEqualToString:kLoginExistKey]){
        return SNWSLoginExistService;
    }else if([akey isEqualToString:kGetAccountKey]){
        return SNWSGetAccount;
    }else if([akey isEqualToString:kLoginGuestKey]){
        return SNWSLoginGuest;
    }else if([akey isEqualToString:kUpdateAccountKey]){
        return SNWSUpdateAccount;
    }else if([akey isEqualToString:kLastConnectionKey]){
        return SNWSLastConnection;
    }else if([akey isEqualToString:kGetLastConnectionKey]){
        return SNWSGetLastConnection;
    }else if([akey isEqualToString:kValidateUsernameKey]){
        return SNWSValidateUsername;
    }else if([akey isEqualToString:kGetServerDateKey]){
        return SNWSGetServerDate;
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
    if ([aKey isEqualToString:kLoginKey]) {
        return [self buildParametersWithName:[self parameterForMethod:kLoginKey key:kLoginNameParameter] username:[self parameterForMethod:kLoginKey key:kLoginUsernameParameter] cloudId:[self parameterForMethod:kLoginKey key:kLoginCloudIdParameter] phoneNumber:[self parameterForMethod:kLoginKey key:kLoginPhoneParameter] idAccount:[self parameterForMethod:kLoginKey key:kLoginIdAccountParameter]];
    }else if([aKey isEqualToString:kSearchKey]){
        return [self buildParameterWithUsername:[self parameterForMethod:kSearchKey key:kSearchUsernameParameter]];
    }else if([aKey isEqualToString:kUpdateCloudIdKey]){
        return [self buildParameterWithCloudId:[self parameterForMethod:kUpdateCloudIdKey key:kUpdateCloudIdParameter] username:[self parameterForMethod:kUpdateCloudIdKey key:kUpdateCloudIdUsernameParameter]];
    }else if ([aKey isEqualToString:kVerifyStateAccountKey]){
        return [self buildParameterWithAccountId:[self parameterForMethod:kVerifyStateAccountKey key:kVerifyStateAccountIdParameter]];
    }else if([aKey isEqualToString:kLoginExistKey]){
        return [self buildParameterWithPhone:[self parameterForMethod:kLoginExistKey key:kLoginExistPhoneParameter] cloudId:[self parameterForMethod:kLoginExistKey key:kLoginExistCloudIdParameter] idAccount:[self parameterForMethod:kLoginExistKey key:kLoginExistIdAccountParameter]];
    }else if([aKey isEqualToString:kGetAccountKey]){
        return [self buildParameterWithUsername:[self parameterForMethod:kGetAccountKey key:kGetAccountUsernameParameter]];
    }else if([aKey isEqualToString:kLoginGuestKey]){
        return [self buildParameterWithCloudId:[self parameterForMethod:kLoginGuestKey key:kLoginGuestCloudIdParameter] username:[self parameterForMethod:kLoginGuestKey key:kLoginGuestUsernameParameter]];
    }else if([aKey isEqualToString:kUpdateAccountKey]){
        return nil;
    }else if([aKey isEqualToString:kLastConnectionKey]){
        return [self buildParameterWithDate:[self parameterForMethod:kLastConnectionKey key:kLastConnectionDateParameter] username:[self parameterForMethod:kLastConnectionKey key:kLastConnectionUsernameParameter] isConnect:[self parameterForMethod:kLastConnectionKey key:kLastConnectionIsConnectParameter]];
    }else if([aKey isEqualToString:kGetLastConnectionKey]){
        return [self buildParameterWithUsername:[self parameterForMethod:kGetLastConnectionKey key:kGetLastConnectionUsernameParameter]];
    }else if([aKey isEqualToString:kValidateUsernameKey]){
        return [self buildParameterWithUsername:[self parameterForMethod:kValidateUsernameKey key:kValidateUsernameParameter]];
    }else if([aKey isEqualToString:kGetServerDateKey]){
        return [NSDictionary dictionary];
    }else{
        return nil;
    }
}
-(void)cancelRequestForKey:(NSString*)aKey{
    if ([aKey isEqualToString:kLoginKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginService];
    }
    if ([aKey isEqualToString:kSearchKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSSearchService];
    }
    if ([aKey isEqualToString:kUpdateCloudIdKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUpdateCloudId];
    }
    if ([aKey isEqualToString:kVerifyStateAccountKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSVerifyStateAccount];
    }
    if ([aKey isEqualToString:kLoginExistKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginExistService];
    }
    if ([aKey isEqualToString:kGetAccountKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetAccount];
    }
    if ([aKey isEqualToString:kLoginGuestKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLoginGuest];
    }
    if ([aKey isEqualToString:kUpdateAccountKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSUpdateAccount];
    }
    if ([aKey isEqualToString:kLastConnectionKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSLastConnection];
    }
    if ([aKey isEqualToString:kGetLastConnectionKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetLastConnection];
    }
    if ([aKey isEqualToString:kValidateUsernameKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSValidateUsername];
    }
    if ([aKey isEqualToString:kGetServerDateKey]) {
        [[SNObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodPOST matchingPathPattern:SNWSGetServerDate];
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
        void(^failure)(NSError* error)=[self parameterForMethod:key key:kFailureParameterAccount];
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

-(id)verifyParameter:(id)parameter{
    if (parameter) {
        return parameter;
    }else{
        return [NSNull null];
    }
}

@end