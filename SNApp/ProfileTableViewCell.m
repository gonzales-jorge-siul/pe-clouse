//
//  ProfileTableViewCell.m
//  SNApp
//
//  Created by Force Close on 8/2/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ProfileTableViewCell.h"

@interface ProfileTableViewCell ()

@end

@implementation ProfileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.enabled = NO;
        [self.contentView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.enabled = NO;
        [self.contentView addSubview:_contentLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.enabled = NO;
        [self.contentView addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.numberOfLines = 0;
        _contentLabel.enabled = NO;
        [self.contentView addSubview:_contentLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView setFrame:[self _contentViewFrame]];
    [self.titleLabel setFrame:[self _titleLabelFrame]];
    [self.contentLabel setFrame:[self _contentLabelFrame]];
}

-(CGRect)_contentViewFrame{
    return CGRectMake(5, 5, self.bounds.size.width-2*5, self.bounds.size.height-2*5);
}

-(CGRect)_titleLabelFrame{
    return CGRectMake(10, 6, self.contentView.bounds.size.width - 2*10, 1.1f*self.titleLabel.font.lineHeight);
}
-(CGRect)_contentLabelFrame{
    CGSize contentTextSize = [self _contentLabelTextSize];
    return CGRectMake(10, 2 + 6+ 1.1f*self.titleLabel.font.lineHeight, contentTextSize.width, contentTextSize.height);
}
-(CGSize)_contentLabelTextSize{
    NSString* text = self.contentLabel.text;
    return [text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 2*10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.contentLabel.font} context:nil].size;
}
+(CGFloat)heightForText:(NSString*)text frame:(CGRect)frame{
    CGFloat height = 6+1.1f*[UIFont systemFontOfSize:14.0f].lineHeight;
    height += [text boundingRectWithSize:CGSizeMake(frame.size.width - 2*10 -2*5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.f]} context:nil].size.height;
    height += (2 + 6 + 2*5);
    return height;
}
@end
