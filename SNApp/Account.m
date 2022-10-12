//
//  Account.m
//  SNApp
//
//  Created by Force Close on 7/6/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "Account.h"
#import "Chat.h"
#import "Comment.h"
#import "Preferences.h"

@implementation Account

@dynamic idAccount;
@dynamic birth;
@dynamic name;
@dynamic photo;
@dynamic state;
@dynamic status;
@dynamic username;
@dynamic likes;
@dynamic chat;
@dynamic comments;

+(NSNumber *)accountId{
    return [Preferences UserAccountId];
}
+(void)setAccountId:(NSNumber *)accountId{
    [Preferences setUserAccountId:accountId];
}
+(NSString *)username{
    return [Preferences Username];
}
+(void)setUsername:(NSString *)username{
    [Preferences setUsername:username];
}
+(NSString *)cloudId{
    return [Preferences UserCloudId];
}
+(void)setCloudId:(NSString *)cloudId{
    [Preferences setUserCloudId:cloudId];
}
+(NSNumber *)state{
    return [Preferences UserState];
}
+(void)setState:(NSNumber *)state{
    [Preferences setUserState:state];
}
+(CLLocationCoordinate2D)lastPosition{
    return [Preferences UserLastPosition];
}
+(void)setLastPosition:(CLLocationCoordinate2D)lastLocation{
    [Preferences setUserLastPosition:lastLocation];
}

@end
