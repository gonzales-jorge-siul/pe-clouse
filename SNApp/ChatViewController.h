//
//  ChatViewController.h
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

@interface ChatViewController : UIViewController

@property(nonatomic,strong)NSManagedObjectContext* managedObjectContext;
@property(nonatomic,strong)Chat* chat;

@end
