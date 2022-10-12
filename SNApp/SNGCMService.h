//
//  SNGCMService.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Google/CloudMessaging.h>

@interface SNGCMService : NSObject<GGLInstanceIDDelegate>

extern NSString* const GCMMesageReceive;
extern NSString* const GCMRegistrationComplete;

+(instancetype)sharedInstance;
-(void)connect;
-(void)disconnect;
-(void)getRegistrationToken;
-(void)getRegistrationTokenWithDeviceToken:(NSData*) deviceToken;
-(void)configureContext;
-(void)startWithConfiguration;
@end
