//
//  Location.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * idLocation;
@property (nonatomic, retain) NSString * latlng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
