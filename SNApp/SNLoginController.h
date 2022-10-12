//
//  SNLoginController.h
//  SNApp
//
//  Created by Force Close on 7/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface SNLoginController : NSObject

+(instancetype)sharedController;

typedef NS_ENUM(NSInteger, SNLoginType) {
    SNLoginTypeUnverified=2,
    SNLoginTypeNormal=0,
    SNLoginTypeExpandFunctions=1,
    SNLoginTypeDirect=3
};

-(void)startLogin:(SNLoginType)loginType;
-(void)dismissLogin;

-(void)verifyAccountId;
-(SNAccountState)verifyAccount;
-(BOOL)verifyIsGuest;
-(BOOL)verifyIsLogin;

-(void)registerAsGuest:(void (^)(BOOL success, NSError* error))result;
-(void)showMessage:(NSString*)message title:(NSString*)title;
@end
