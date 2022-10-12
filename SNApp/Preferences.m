//
//  Preferences.m
//  SNApp
//
//  Created by Force Close on 6/11/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

//Navigation Login
NSString* const NAVIGATION_LOGIN_PAGE = @"SNNavigationLoginPage";
NSString* const NAVIGATION_LOGIN_NUMBER_PHONE =@"SNNavigationLoginNumberPhone";
NSString* const NAVIGATION_LOGIN_NAME =@"SNNavigationLoginName";
//NSString* const NAVIGATION_LOGIN =@"SNNavigationLogin";

//User
NSString* const USER_STATE = @"SNUserState";
NSString* const USER_ACCOUNT_ID =@"SNUserAccountId";
NSString* const USERNAME =@"SNUsername";
NSString* const USER_RADIUS =@"SNUserRadius";
NSString* const USER_STEP_RADIUS =@"SNUserStepRadius";
NSString* const USER_LAST_POSITION =@"SNUserLastPosition";
NSString* const USER_IS_LOGIN =@"SNUserIsLogin";
NSString* const USER_CLOUD_ID =@"SNUserCloudId";
NSString* const USER_TIMES_TRY_LOGIN =@"SNUserTimesTryLogin";
NSString* const USER_IS_GUEST =@"SNUserIsGuest";
//NSString* const USER_ =@"SNUser";

//Notification
NSString* const NOTIFICATION_CHAT = @"SNNotificationChat";
NSString* const NOTIFICATION_NEAR_POST =@"SNNotificationNearPost";

//Camera
NSString* const CAMERA_FLASH_MODE =@"SNCameraFlashMode";
NSString* const CAMERA_DEVICE =@"SNCameraDevice";
//NSString* const CAMERA_ =@"SNCamera";

//GCM
NSString* const GCM_SENDER_ID =@"SNGCMSenderId";
NSString* const GCM_IS_RECEIVED_TOKEN =@"SNGCMIsReceivedToken";
NSString* const GCM_IS_CONNECT =@"SNGCMIsConnect";
//NSString* const GCM_ =@"SNGCM";

//APP
NSString* const APP_FLAG = @"SNAppFlag";

//Position Dictionary Keys
NSString* const kLatitude =@"SNLatitude";
NSString* const kLongitude =@"SNLongitude";

+(void)setInitialDefaults{
    NSString *defaultsFile = [[NSBundle mainBundle] pathForResource:@"SNUserDefaults" ofType:@"plist"];
    NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:defaultsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

//Navigation Login
+(SNNavigationLoginPage)NavigationLoginPage{
    switch ([[self numberForKey:NAVIGATION_LOGIN_PAGE] integerValue]) {
        case 0:
            return SNNavigationLoginPageLogin;
        case 1:
            return SNNavigationLoginPageVerification;
        case 2:
            return SNNavigationLoginPagePersonalData;
        default:
            return -1;
    }
}
+(void)setNavigationLoginPage:(SNNavigationLoginPage)value{
    [self setNumber:[NSNumber numberWithInteger:value] forKey:NAVIGATION_LOGIN_PAGE];
}
+(NSString*)NavigationLoginNumberPhone{
    return [self stringForKey:NAVIGATION_LOGIN_NUMBER_PHONE];
}
+(void)setNavigationLoginNumberPhone:(NSString*)value{
    [self setString:value forKey:NAVIGATION_LOGIN_NUMBER_PHONE];
}
+(NSString*)NavigationLoginName{
    return [self stringForKey:NAVIGATION_LOGIN_NAME];
}
+(void)setNavigationLoginName:(NSString*)value{
    [self setString:value forKey:NAVIGATION_LOGIN_NAME];
}

//User
+(NSNumber *)UserAccountId{
    return [self numberForKey:USER_ACCOUNT_ID];
}
+(void)setUserAccountId:(NSNumber *)value{
    [self setNumber:value forKey:USER_ACCOUNT_ID];
}
+(NSString*)Username{
    return [self stringForKey:USERNAME];
}
+(void)setUsername:(NSString*)value{
    [self setString:value forKey:USERNAME];
}
+(NSString*)UserCloudId{
    return [self stringForKey:USER_CLOUD_ID];
}
+(void)setUserCloudId:(NSString*)value{
    [self setString:value forKey:USER_CLOUD_ID];
}
+(NSNumber *)UserState{
    return [self numberForKey:USER_STATE];
}
+(void)setUserState:(NSNumber *)value{
    [self setNumber:value forKey:USER_STATE];
}
+(NSNumber*)UserIsLogin{
    return [self numberForKey:USER_IS_LOGIN];
}
+(void)setUserIsLogin:(NSNumber*)value{
    [self setNumber:value forKey:USER_IS_LOGIN];
}
+(NSNumber *)UserIsGuest{
    return [self numberForKey:USER_IS_GUEST];
}
+(void)setUserIsGuest:(NSNumber *)value{
    [self setNumber:value forKey:USER_IS_GUEST];
}
+(NSNumber *)UserTimesTryLogin{
    return  [self numberForKey:USER_TIMES_TRY_LOGIN];
}
+(void)setUserTimesTryLogin:(NSNumber *)value{
    [self setNumber:value forKey:USER_TIMES_TRY_LOGIN];
}
+(NSNumber*)UserRadius{
    return [self numberForKey:USER_RADIUS];
}
+(void)setUserRadius:(NSNumber*)value{
    [self setNumber:value forKey:USER_RADIUS];
}
+(NSNumber*)UserStepRadius{
    return [self numberForKey:USER_STEP_RADIUS];
}
+(void)setUserStepRadius:(NSNumber*)value{
    [self setNumber:value forKey:USER_STEP_RADIUS];
}
+(CLLocationCoordinate2D)UserLastPosition{
    NSDictionary* location = [self dictionaryForKey:USER_LAST_POSITION];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[location objectForKey:kLatitude] doubleValue];
    coordinate.longitude = [[location objectForKey:kLongitude] doubleValue];
    return coordinate;
}
+(void)setUserLastPosition:(CLLocationCoordinate2D)value{
    NSDictionary* location = [NSDictionary dictionaryWithObjects:@[@(value.latitude),@(value.longitude)] forKeys:@[kLatitude,kLongitude]];
    [self setObject:location forKey:USER_LAST_POSITION];
}

//Notification
+(NSNumber*)NotificationChats{
    return [self numberForKey:NOTIFICATION_CHAT];
}
+(void)setNotificationChats:(NSNumber*)value{
    [self setNumber:value forKey:NOTIFICATION_CHAT];
}
+(NSNumber*)NotificationNearPost{
    return [self numberForKey:NOTIFICATION_NEAR_POST];
}
+(void)setNotificationNearPost:(NSNumber*)value{
    [self setNumber:value forKey:NOTIFICATION_NEAR_POST];
}

//Camera
+(NSNumber*)CameraFlashMode{
    return [self numberForKey:CAMERA_FLASH_MODE];
}
+(void)setCameraFlashMode:(NSNumber*)value{
    [self setNumber:value forKey:CAMERA_FLASH_MODE];
}
+(NSNumber*)CameraDevice{
    return [self numberForKey:CAMERA_DEVICE];
}
+(void)setCameraDevice:(NSNumber*)value{
    [self setNumber:value forKey:CAMERA_DEVICE];
}

//GCM
+(NSString*)GCMSenderId{
    return [self stringForKey:GCM_SENDER_ID];
}
+(void)setGCMSenderId:(NSString*)value{
    [self setString:value forKey:GCM_SENDER_ID];
}
+(NSNumber*)GCMIsReceivedToken{
    return [self numberForKey:GCM_IS_RECEIVED_TOKEN];
}
+(void)setGCMIsReceivedToken:(NSNumber*)value{
    [self setObject:value forKey:GCM_IS_RECEIVED_TOKEN];
}
+(NSNumber*)GCMIsConnect{
    return [self numberForKey:GCM_IS_CONNECT];
}
+(void)setGCMIsConnect:(NSNumber*)value{
    [self setNumber:value forKey:GCM_IS_CONNECT];
}

//APP
+(NSNumber *)AppFlag{
    return [self numberForKey:APP_FLAG];
}
+(void)setAppFlap:(NSNumber *)value{
    [self setNumber:value forKey:APP_FLAG];
}

#pragma mark - Helpers

+(NSString *)stringForKey:(NSString*)key{
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    NSString* returnValue = [userDefaults stringForKey:key];
    return returnValue;
}

+(void)setString:(NSString*)value forKey:(NSString*)key{
    [self setObject:value forKey:key];
}

+(NSNumber *)numberForKey:(NSString*)key{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* returnValue = (NSNumber*)[userDefaults objectForKey:key];
    return returnValue;
}

+(void)setNumber:(NSNumber*)value forKey:(NSString*)key{
    [self setObject:value forKey:key];
}

+(void)setObject:(id)value forKey:(NSString*)key{
    NSUserDefaults* userDefaults =[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+(NSDictionary*)dictionaryForKey:(NSString*)key{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* returnValue = (NSDictionary*)[userDefaults dictionaryForKey:key];
    return returnValue;
}

@end
