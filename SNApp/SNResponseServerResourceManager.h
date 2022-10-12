//
//  SNResponseServerResourceManager.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseServer.h"

@interface SNResponseServerResourceManager : NSObject

extern NSString* const SNWSAuthenticate;

+(instancetype)sharedManager;

-(void)authenticatePhone:(NSString*)number success:(void(^)(ResponseServer *response))success failure:(void(^)(NSError *error))failure;
-(void)cancelAuthenticationPhone;

@end
