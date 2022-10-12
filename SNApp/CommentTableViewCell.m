//
//  CommentTableViewCell.m
//  SNApp
//
//  Created by Force Close on 6/29/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "CommentTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+SNColors.h"
#import "SNDate.h"

@interface CommentTableViewCell ()

@property(nonatomic,strong)UIImageView* photoView;
@property(nonatomic,strong)UIImageView* backImageView;
@property(nonatomic,strong)UILabel* nameView;
@property(nonatomic,strong)UILabel* commentView;
@property(nonatomic,strong)UILabel* dateView;

@end

@implementation CommentTableViewCell

#pragma mark - Life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Photo view
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.contentMode = UIViewContentModeScaleToFill;
        _photoView.layer.cornerRadius = 4.0;
        _photoView.clipsToBounds =YES;
        [self.contentView addSubview:_photoView];
        
        //Back image view
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage* bubbleImage=[[UIImage imageNamed:@"bubbleIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 8, 8) resizingMode:UIImageResizingModeStretch];
        _backImageView.image = bubbleImage;
        [self.contentView addSubview:_backImageView];
        
        //Name view
        _nameView = [[UILabel alloc]initWithFrame:CGRectZero];
        _nameView.font = [UIFont systemFontOfSize:FONT_SIZE_NAME_CTVC];
        _nameView.textColor = [UIColor appMainColor];
        _nameView.numberOfLines = 1;
        [_backImageView addSubview:_nameView];
        
        //Date view
        _dateView = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateView.font = [UIFont systemFontOfSize:14.0];
        _dateView.textColor = [UIColor grayColor];
        _dateView.textAlignment = NSTextAlignmentRight;
        _dateView.numberOfLines = 1;
        [_backImageView addSubview:_dateView];
        
        //Comment view
        _commentView = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentView.font = [UIFont systemFontOfSize:FONT_SIZE_COMMENT_CTVC];
        _commentView.textColor = [UIColor blackColor];
        _commentView.textAlignment = NSTextAlignmentLeft;
        _commentView.numberOfLines =0;
        [_backImageView addSubview:_commentView];
        
        //Content View
        self.contentView.backgroundColor = [UIColor gray200Color];
        
        //Cell
        self.backgroundColor = [UIColor gray200Color];
    }
    return self;
}

-(void)layoutSubviews{
    [self.photoView setFrame:[self _photoViewFrame]];
    [self.backImageView setFrame:[self _backImageViewFrame]];
    [self.nameView setFrame:[self _nameViewFrame]];
    [self.dateView setFrame:[self _dateViewFrame]];
    [self.commentView setFrame:[self _commentViewFrame]];
}

#pragma mark - Constants
//Content view
CGFloat const CONTENT_VIEW_LATERAL_MARGIN = 5.0;
CGFloat const CONTENT_VIEW_UPPER_MARGIN = 3.0;
//Photo
CGFloat const PHOTO_HEIGHT=44.0;
CGFloat const PHOTO_LATERAL_MARGIN=6.0;
CGFloat const PHOTO_UPPER_MARGIN=4.0;
//Back image
CGFloat const BACK_IMAGE_LATERAL_MARGIN =8.0;
CGFloat const BACK_IMAGE_UPPER_MARGIN =6.0;
//Name
CGFloat const NAME_LEFT_MARGIN=14.0;
CGFloat const NAME_RIGHT_MARGIN=8.0;
CGFloat const NAME_UPPER_MARGIN=4.0;
CGFloat const FONT_SIZE_NAME_CTVC =14.f;
//Date
CGFloat const DATE_LEFT_MARGIN=18.0;
CGFloat const DATE_RIGHT_MARGIN=6.0;
CGFloat const DATE_UPPER_MARGIN=4.0;
//Comment
CGFloat const COMMENT_LEFT_MARGIN =18.0;
CGFloat const COMMENT_RIGHT_MARGIN =6.0;
CGFloat const COMMENT_UPPER_MARGIN =4.0;
CGFloat const COMMENT_BOTTOM_MARGIN =9.0;
CGFloat const FONT_SIZE_COMMENT_CTVC = 16.f;

#pragma mark - Helpers layout

-(CGRect)_photoViewFrame{
    return CGRectMake(PHOTO_LATERAL_MARGIN , PHOTO_UPPER_MARGIN, PHOTO_HEIGHT , PHOTO_HEIGHT);
}

-(CGRect)_backImageViewFrame{
    CGFloat totalLeftMargin = PHOTO_LATERAL_MARGIN + PHOTO_HEIGHT + BACK_IMAGE_LATERAL_MARGIN;
    return CGRectMake(totalLeftMargin, BACK_IMAGE_UPPER_MARGIN, self.contentView.bounds.size.width - totalLeftMargin - BACK_IMAGE_LATERAL_MARGIN, self.contentView.bounds.size.height-2*BACK_IMAGE_UPPER_MARGIN);
}

-(CGRect)_nameViewFrame{
    return CGRectMake(NAME_LEFT_MARGIN, NAME_UPPER_MARGIN, self.backImageView.bounds.size.width - NAME_LEFT_MARGIN-NAME_RIGHT_MARGIN, 1.1*self.nameView.font.lineHeight);
}
-(CGRect)_dateViewFrame{
    return CGRectMake(DATE_LEFT_MARGIN, DATE_UPPER_MARGIN, self.backImageView.bounds.size.width - DATE_LEFT_MARGIN-DATE_RIGHT_MARGIN, 1.1*self.dateView.font.lineHeight);
}
-(CGRect)_commentViewFrame{
    CGSize commentTextSize = [self _commentTextSize];
    return CGRectMake(COMMENT_LEFT_MARGIN, COMMENT_UPPER_MARGIN + 1.1*self.nameView.font.lineHeight + NAME_UPPER_MARGIN, self.backImageView.bounds.size.width - COMMENT_LEFT_MARGIN -COMMENT_RIGHT_MARGIN, commentTextSize.height );
}

-(CGSize)_commentTextSize{
    NSString* string= self.commentText;
    return [string boundingRectWithSize:CGSizeMake(self.backImageView.bounds.size.width - COMMENT_LEFT_MARGIN - COMMENT_RIGHT_MARGIN, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.commentView.font} context:nil].size;
}

+(CGFloat)heightForText:(NSString*)text frame:(CGRect)frame{
    CGFloat height = 1.1*[UIFont systemFontOfSize:FONT_SIZE_NAME_CTVC].lineHeight + NAME_UPPER_MARGIN + COMMENT_UPPER_MARGIN +2*BACK_IMAGE_UPPER_MARGIN +COMMENT_BOTTOM_MARGIN;
    height += [text boundingRectWithSize:CGSizeMake(frame.size.width - PHOTO_LATERAL_MARGIN - PHOTO_HEIGHT - 2*BACK_IMAGE_LATERAL_MARGIN - COMMENT_LEFT_MARGIN - COMMENT_RIGHT_MARGIN , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:FONT_SIZE_COMMENT_CTVC]} context:nil].size.height;
    //CGFloat minHeight =1.1*[UIFont systemFontOfSize:FONT_SIZE_NAME_CTVC].lineHeight + NAME_UPPER_MARGIN + COMMENT_UPPER_MARGIN +2*BACK_IMAGE_UPPER_MARGIN +COMMENT_BOTTOM_MARGIN + 1*[UIFont systemFontOfSize:FONT_SIZE_COMMENT_CTVC].lineHeight;
    //return height>=minHeight?height:minHeight;
    return height;
}


#pragma mark - Custom accessors

-(void)setPhotoText:(NSString *)photoText{
    _photoText= photoText;

    if ([self.photoText isEqualToString:@""]) {
        [self.photoView setImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    }else{
        [self.photoView setImageWithURL:[NSURL URLWithString:self.photoText] placeholderImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    }
}

-(void)setNameText:(NSString *)nameText{
    _nameText = nameText;
    
    self.nameView.text =self.nameText;
    [self.nameView setNeedsDisplay];
}

-(void)setDate:(NSDate *)date{
    _date = date;
    self.dateView.text = [self textForDate:self.date];
    [self.dateView setNeedsDisplay];
}

-(void)setCommentText:(NSString *)commentText{
    _commentText = commentText;
    self.commentView.text =self.commentText;
    [self.commentView setNeedsDisplay];
}

#pragma mark - Helpers

-(NSString*)textForDate:(NSDate*)date{ 
    double secondsInPost = [date timeIntervalSinceDate:[SNDate serverDate]];
    //secondsInPost -= 14400;
    if (secondsInPost<0) {
        secondsInPost = -1*secondsInPost;
        if (secondsInPost<60) {
            int seconds = secondsInPost;
            return [NSString stringWithFormat:NSLocalizedString(@"comment.cell.%dsec", @"{number of seconds}sec"),seconds];
        }else if(secondsInPost<3600){
            int minutes = secondsInPost/60;
            return [NSString stringWithFormat:NSLocalizedString(@"comment.cell.%dmin", @"{number of minutes}min"),minutes];
        }else if(secondsInPost<86400){
            int hours = secondsInPost/3600;
            return [NSString stringWithFormat:NSLocalizedString(@"comment.cell.%dh", @"{number of  hours}h"),hours];
        }else if (secondsInPost<604800){
            int days = secondsInPost/86400;
            return [NSString stringWithFormat:NSLocalizedString(@"comment.cell.%dd", @"{number of days}d"),days];
        }else{
            int weeks = secondsInPost/604800;
            return [NSString stringWithFormat:NSLocalizedString(@"comment.cell.%dw", @"{number of weeks}w"),weeks];
        }
    }else{
        return NSLocalizedString(@"app.general.At future", @"just for test");
    }
}

@end
