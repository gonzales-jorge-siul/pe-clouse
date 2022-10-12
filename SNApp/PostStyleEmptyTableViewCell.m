//
//  PostStyleEmptyTableViewCell.m
//  SNApp
//
//  Created by Force Close on 8/12/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostStyleEmptyTableViewCell.h"

@interface PostStyleEmptyTableViewCell ()

@property (nonatomic, strong) UIImageView* initialImageView;

@end

@implementation PostStyleEmptyTableViewCell

#pragma mark - Life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _initialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteImage"]];
        _initialImageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:_initialImageView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.initialImageView setFrame:[self _initialImageViewFrame]];
}

#pragma mark - Helpers layout

-(CGRect)_initialImageViewFrame{
    return CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

@end
