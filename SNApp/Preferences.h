//
//  Preferences.h
//  SNApp
//
//  Created by Force Close on 6/11/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Preferences : NSObject

extern NSString* const kLatitude;
extern NSString* const kLongitude;

typedef NS_ENUM(NSInteger, SNNavigationLoginPage) {
    SNNavigationLoginPageLogin = 0,
    SNNavigationLoginPageVerification = 1,
    SNNavigationLoginPagePersonalData = 2
};

+(void)setInitialDefaults;

//Navigation Login
+(SNNavigationLoginPage)NavigationLoginPage;
+(void)setNavigationLoginPage:(SNNavigationLoginPage)value;
+(NSString*)NavigationLoginNumberPhone;
+(void)setNavigationLoginNumberPhone:(NSString*)value;
+(NSString*)NavigationLoginName;
+(void)setNavigationLoginName:(NSString*)value;
//+(NSNumber*)NavigationLogin;
//+(void)setNavigationLogin:(NSNumber*)value;

//User
+(NSNumber*)UserAccountId;
+(void)setUserAccountId:(NSNumber*)value;
+(NSString*)Username;
+(void)setUsername:(NSString*)value;
+(NSString*)UserCloudId;
+(void)setUserCloudId:(NSString*)value;
+(NSNumber*)UserState;
+(void)setUserState:(NSNumber*)value;
+(NSNumber*)UserIsLogin;
+(void)setUserIsLogin:(NSNumber*)value;
+(NSNumber*)UserIsGuest;
+(void)setUserIsGuest:(NSNumber*)value;
+(NSNumber*)UserRadius;
+(void)setUserRadius:(NSNumber*)value;
+(NSNumber*)UserStepRadius;
+(void)setUserStepRadius:(NSNumber*)value;
+(CLLocationCoordinate2D)UserLastPosition;
+(void)setUserLastPosition:(CLLocationCoordinate2D)value;
+(NSNumber*)UserTimesTryLogin;
+(void)setUserTimesTryLogin:(NSNumber*)value;
//+(NSNumber*)User;
//+(void)setUser:(NSNumber*)value;

//Notification
+(NSNumber*)NotificationChats;
+(void)setNotificationChats:(NSNumber*)value;
+(NSNumber*)NotificationNearPost;
+(void)setNotificationNearPost:(NSNumber*)value;

//Camera
+(NSNumber*)CameraFlashMode;
+(void)setCameraFlashMode:(NSNumber*)value;
+(NSNumber*)CameraDevice;
+(void)setCameraDevice:(NSNumber*)value;
//+(NSNumber*)Camera;
//+(void)setCamera:(NSNumber*)value;


//GCM
+(NSString*)GCMSenderId;
+(void)setGCMSenderId:(NSString*)value;
+(NSNumber*)GCMIsReceivedToken;
+(void)setGCMIsReceivedToken:(NSNumber*)value;
+(NSNumber*)GCMIsConnect;
+(void)setGCMIsConnect:(NSNumber*)value;
//+(NSNumber*)GCM;
//+(void)setGCM:(NSNumber*)value;

//APP
+(NSNumber*)AppFlag;
+(void)setAppFlap:(NSNumber*)value;

@end
