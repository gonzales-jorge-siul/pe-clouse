//
//  Post.h
//  SNApp
//
//  Created by Force Close on 7/3/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Activity, Comment, Location;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * delete;
@property (nonatomic, retain) NSNumber * idAccount;
@property (nonatomic, retain) NSNumber * idLocation;
@property (nonatomic, retain) NSNumber * idPost;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * like;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSNumber * numComment;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSSet *activityLog;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSNumber * distance;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addActivityLogObject:(Activity *)value;
- (void)removeActivityLogObject:(Activity *)value;
- (void)addActivityLog:(NSSet *)values;
- (void)removeActivityLog:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
