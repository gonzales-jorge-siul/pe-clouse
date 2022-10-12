//
//  CommentListView.h
//  SNApp
//
//  Created by Force Close on 6/30/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@interface CommentListView : UIView

@property(nonatomic,strong)Post* post;
@property(nonatomic,strong)UITextField* commentText;
@property(nonatomic,strong)UIButton* sendButton;
@property(nonatomic,strong)UITableView* tableView;

@property(nonatomic,weak)UIButton* surprisedButton;

@end
