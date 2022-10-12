//
//  SNChatResourceManager.h
//  SNApp
//
//  Created by Force Close on 8/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseServer.h"

@interface SNChatResourceManager : NSObject

+(instancetype)sharedManager;

-(void)sendMessage:(NSString *)message from:(NSString *)fromUsername to:(NSString *)toUsername success:(void (^)(ResponseServer *))success failure:(void (^)(NSError *))failure;
-(void)cancelSendMessage;

-(void)getChats:(NSString *)aUsername interlocutor:(NSString *)aInterlocutor date:(NSDate *)date success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
-(void)cancelGetChats;

@end
