//
//  MyProfileTableViewCell.h
//  SNApp
//
//  Created by Force Close on 10/2/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileTableViewCell : UITableViewCell

@property(nonatomic,strong)UITextField* titleLabel;
@property(nonatomic,strong)UITextField* contentLabel;

+(CGFloat)heightForText:(NSString*)text frame:(CGRect)frame;

@end
