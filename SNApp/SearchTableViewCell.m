//
//  SearchTableViewCell.m
//  SNApp
//
//  Created by Force Close on 7/16/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self bringSubviewToFront:self.imageView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(self.contentView.bounds.size.width-44-6, 11, 44, 44)];
    [self.textLabel setFrame:CGRectMake(18, 11, self.contentView.bounds.size.width-56 - 18, 20)];
    [self.detailTextLabel setFrame:CGRectMake(18, 33, self.contentView.bounds.size.width-56 -18 , 16)];
}

@end
