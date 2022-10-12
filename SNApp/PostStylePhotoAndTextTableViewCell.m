//
//  PostStylePhotoAndTextTableViewCell.m
//  SNApp
//
//  Created by Force Close on 7/27/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostStylePhotoAndTextTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+SNColors.h"
#import "StatisticsFrameView.h"

@interface PostStylePhotoAndTextTableViewCell ()

@property(nonatomic, strong)UIImageView* image;
@property(nonatomic, strong)StatisticsFrameView* statisticsView;
@property(nonatomic, strong)UILabel* contentText;
@property(nonatomic, strong)UIView* rectangle;

@end

@implementation PostStylePhotoAndTextTableViewCell

@synthesize wowButton = _wowButton;
@synthesize post = _post;

#pragma mark - Life cycle
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _image = [[UIImageView alloc] initWithFrame:CGRectZero];
        _image.contentMode = UIViewContentModeScaleToFill;
        _image.backgroundColor = [UIColor  whiteColor];
        _image.layer.cornerRadius =5.0;
        _image.clipsToBounds =YES;
        _image.userInteractionEnabled = YES;
        [self.contentView addSubview:_image];
        
        _statisticsView = [[StatisticsFrameView alloc] initWithFrame:CGRectMake(0, 260, 312, 60) style:SNStatisticsStyleDarkTransluce];
        [_image addSubview:_statisticsView];
        
        _wowButton=_statisticsView.surprisedButton;
        
        _rectangle = [[UIView alloc] initWithFrame:CGRectZero];
        _rectangle.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        [_image addSubview:_rectangle];
        
        _contentText = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentText setFont:[UIFont systemFontOfSize:16.0]];
        [_contentText setTextColor:[UIColor whiteColor]];
        _contentText.numberOfLines =2;
        _contentText.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentText.textAlignment = NSTextAlignmentLeft;
        [_rectangle addSubview:_contentText];
        
        self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.contentView.layer.shadowOffset = CGSizeMake(0,0.4);
        self.contentView.layer.shadowOpacity = 0.2;
        
        self.contentView.clipsToBounds = NO;
        self.clipsToBounds =NO;
        self.backgroundColor = [UIColor gray200Color];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.contentView setFrame:[self _contentViewFrame]];
    [self.image setFrame:[self _imageViewFrame]];
    [self.rectangle setFrame:[self _rectangleFrame]];
    [self.contentText setFrame:[self _contentTextFrame]];
    [self.statisticsView setFrame:[self _statisticsViewFrame]];
}

//Content
static CGFloat const C_LATERAL_MARGIN = 6.0;
static CGFloat const C_UPPER_MARGIN =2.0;
//Content view
static CGFloat const CELL_LEFT_MARGIN = 7.0;
static CGFloat const CELL_UPPER_MARGIN = 7.0;

-(CGRect)_contentViewFrame{
    return CGRectMake(CELL_LEFT_MARGIN, CELL_UPPER_MARGIN, self.bounds.size.width - 2*CELL_LEFT_MARGIN, self.bounds.size.height-2*CELL_UPPER_MARGIN);
}
-(CGRect)_imageViewFrame{
    return CGRectMake(0, 0, self.contentView.bounds.size.width,self.contentView.bounds.size.height);
}
-(CGRect)_contentTextFrame{
    return CGRectMake(C_LATERAL_MARGIN,C_UPPER_MARGIN, self.rectangle.bounds.size.width-2*C_LATERAL_MARGIN,self.rectangle.bounds.size.height-C_UPPER_MARGIN);
}
-(CGRect)_rectangleFrame{
    CGSize contentTextSize = [self _contentTextSize];
    return CGRectMake(0, self.contentView.bounds.size.height - 52 - contentTextSize.height - C_UPPER_MARGIN, self.contentView.bounds.size.width, contentTextSize.height+C_UPPER_MARGIN);
}
-(CGRect)_statisticsViewFrame{
    return CGRectMake(0, self.contentView.bounds.size.height - 52, self.contentView.bounds.size.width, 52);
}
-(CGSize)_contentTextSize{
    NSString* text = self.post.content;
    return [text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width-2*C_LATERAL_MARGIN, self.contentText.font.lineHeight*2.3) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.contentText.font} context:nil].size;
}
#pragma mark - Custom Accessors

-(void)setPost:(Post *)post{
    _post=post;
    self.contentText.text = post.content;
    if (![post.photo isEqualToString:@""]) {
        NSURLRequest *urlRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:post.photo] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [self.image setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"whiteBackground"] success:nil failure:nil];
    }else{
        [self.image setImage:[UIImage imageNamed:@"whiteBackground"]];
    }
    
    self.statisticsView.surprised = self.post.like;
    self.statisticsView.distance = self.post.distance;
    self.statisticsView.creationDate = self.post.creationDate;
    self.statisticsView.numberOfComments = self.post.numComment;
    self.statisticsView.numberOfSurprised = self.post.rate;
}



@end
