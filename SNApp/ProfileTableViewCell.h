//
//  ProfileTableViewCell.h
//  SNApp
//
//  Created by Force Close on 8/2/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UILabel* contentLabel;

+(CGFloat)heightForText:(NSString*)text frame:(CGRect)frame;

@end
