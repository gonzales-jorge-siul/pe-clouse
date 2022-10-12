//
//  Account.h
//  SNApp
//
//  Created by Force Close on 7/6/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Chat, Comment;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSNumber * idAccount;
@property (nonatomic, retain) NSDate * birth;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) Chat *chat;
@property (nonatomic, retain) NSSet *comments;

typedef NS_ENUM(NSInteger, SNAccountState) {
    SNAccountStateRequest =4,
    SNAccountStateGuest =2,
    SNAccountStateBlock=3,
    SNAccountStateNormal=1,
    SNAccountStateUnverified=0
};

+(NSNumber*)accountId;
+(void)setAccountId:(NSNumber*)accountId;
+(NSString*)username;
+(void)setUsername:(NSString*)username;
+(NSString*)cloudId;
+(void)setCloudId:(NSString*)cloudId;
+(NSNumber*)state;
+(void)setState:(NSNumber*)state;
+(CLLocationCoordinate2D)lastPosition;
+(void)setLastPosition:(CLLocationCoordinate2D)lastLocation;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
