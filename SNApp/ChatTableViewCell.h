//
//  ChatTableViewCell.h
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface ChatTableViewCell : UITableViewCell

@property(nonatomic,strong)Message* message;

-(void)showMark;

+(CGFloat)heightForText:(Message*)message frame:(CGRect)frame;

@end
