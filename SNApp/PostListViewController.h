//
//  PostListViewController.h
//  SNApp
//
//  Created by Force Close on 7/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDataSourceProtocol.h"

@interface PostListViewController : UIViewController

@property(nonatomic,strong)id<UITableViewDataSource,PostDataSourceProtocol> dataSource;
@property(nonatomic,strong)NSManagedObjectContext* managedObjectContext;

extern NSString* const SN_POST_STYLE_TEXT_CELL ;
extern NSString* const SN_POST_STYLE_PHOTO_CELL ;
extern NSString* const SN_POST_STYLE_PHOTO_TEXT_CELL ;
extern NSString* const SN_POST_STYLE_EMPTY_CELL;

-(void)scrollToTop:(id)sender;

@end
