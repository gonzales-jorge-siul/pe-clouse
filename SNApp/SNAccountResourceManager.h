//
//  SNAccountResourceManager.h
//  SNApp
//
//  Created by Force Close on 6/16/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "ResponseServer.h"
#import "UserLastConnection.h"
#import "SNServer.h"

@interface SNAccountResourceManager : NSObject

extern NSString* const SNWSLoginService;

+(instancetype)sharedManager;

-(void)loginWithName:(NSString *)name username:(NSString*)username cloudId:(NSString *)cloudId phoneNumber:(NSString *)phoneNumber idAccount:(NSNumber*)idAccount success:(void (^)(Account *))success failure:(void (^)(NSError *))failure;
-(void)cancelLogin;

-(void)loginWithPhone:(NSString *)phone cloudId:(NSString *)cloudId idAccount:(NSNumber*)idAccount success:(void (^)(Account *))success failure:(void (^)(NSError *))failure;

-(void)search:(NSString*)name success:(void(^)(NSArray* results))success failure:(void(^)(NSError* error))failure;
-(void)cancelSearch;

-(void)updateCloudId:(NSString*)cloudId username:(NSString*)username success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelUpdateCloudId;

-(void)verifyStateAccount:(NSNumber*)accountId success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelVerifyStateAccount;

-(void)getAccount:(NSString*)username success:(void(^)(Account* account))success failure:(void(^)(NSError* error))failure;
-(void)cancelGetAccount;

-(void)updateAccountName:(NSString*)name status:(NSString*)status birth:(NSDate*)birth likes:(NSString*)likes photo:(NSURL *)photoURL username:(NSString*)username success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelUpdateAccount;

-(void)loginAsGuest:(NSString*)username cloudId:(NSString*)cloudId success:(void(^)(Account* account))success failure:(void(^)(NSError* error))failure;
-(void)cancelLoginAsGuest;

-(void)lastConnection:(NSDate *)date username:(NSString *)username isConnect:(NSNumber*)isConnect success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure;
-(void)cancelLastConnection;

-(void)getLastConnectionFor:(NSString*)username success:(void(^)(UserLastConnection* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelGetLastConnection;

-(void)validateUsername:(NSString*)username success:(void(^)(ResponseServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelValidateUsername;

-(void)getServerDateWithBlockOnSuccess:(void(^)(SNServer* response))success failure:(void(^)(NSError* error))failure;
-(void)cancelGetServerDate;

@end
