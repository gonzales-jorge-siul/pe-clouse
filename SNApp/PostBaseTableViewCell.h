//
//  PostBaseTableViewCell.h
//  SNApp
//
//  Created by Force Close on 7/27/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostBaseTableViewCell : UITableViewCell

@property(nonatomic,strong) Post* post;
@property(nonatomic, weak)UIButton* wowButton;

-(void)startAnimation;

@end
