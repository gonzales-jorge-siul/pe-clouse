//
//  SNChatController.h
//  SNApp
//
//  Created by Force Close on 8/17/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNNotificationController : NSObject

+(instancetype)sharedController;

-(void)processReceivedNotification:(NSDictionary*)userInfo shouldShowChat:(BOOL)shouldShowChat completionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
