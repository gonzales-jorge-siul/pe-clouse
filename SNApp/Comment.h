//
//  Comment.h
//  SNApp
//
//  Created by Force Close on 7/16/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Post;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * idComment;
@property (nonatomic, retain) NSNumber * idPost;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Post *post;

@end
