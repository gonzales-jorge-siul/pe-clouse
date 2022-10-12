//
//  CommentListViewController.h
//  SNApp
//
//  Created by Force Close on 6/29/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@interface CommentListViewController : UIViewController

@property(nonatomic,strong)Post* post;
@property(nonatomic,strong)NSManagedObjectContext* managedObjectContext;

@end
