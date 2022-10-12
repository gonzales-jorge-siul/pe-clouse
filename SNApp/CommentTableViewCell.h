//
//  CommentTableViewCell.h
//  SNApp
//
//  Created by Force Close on 6/29/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property(nonatomic,strong)NSString* photoText;
@property(nonatomic,strong)NSString* nameText;
@property(nonatomic,strong)NSDate* date;
@property(nonatomic,strong)NSString* commentText;

+(CGFloat)heightForText:(NSString*)text frame:(CGRect)frame;

@end
