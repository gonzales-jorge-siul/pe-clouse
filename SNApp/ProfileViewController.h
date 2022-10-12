//
//  ProfileViewController.h
//  SNApp
//
//  Created by Force Close on 7/4/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@protocol SNProfileDelegate;

@interface ProfileViewController : UIViewController

@property(nonatomic,strong)Account* account;
@property(nonatomic,strong)NSManagedObjectContext* managedObjectContext;
@property(nonatomic,weak)id<SNProfileDelegate> delegate;

@end

@protocol SNProfileDelegate <NSObject>

-(void)profileController:(ProfileViewController*)controller startChat:(Account*)account;

@end