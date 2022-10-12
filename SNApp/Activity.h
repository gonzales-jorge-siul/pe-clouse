//
//  Activity.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Post;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSNumber * idAccount;
@property (nonatomic, retain) NSNumber * idActivity;
@property (nonatomic, retain) NSNumber * idPost;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Post *post;

@end
