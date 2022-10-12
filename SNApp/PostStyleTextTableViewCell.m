//
//  PostTableViewCell.m
//  SNApp
//
//  Created by Force Close on 6/18/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostStyleTextTableViewCell.h"
#import "UIColor+SNColors.h"
#import "StatisticsFrameView.h"

@interface PostStyleTextTableViewCell ()<UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIImageView* backImage;

@property(nonatomic, strong)UILabel* contentText;

@property(nonatomic, strong)StatisticsFrameView* statisticsView;
@end

@implementation PostStyleTextTableViewCell

@synthesize wowButton = _wowButton;
@synthesize post = _post;

#pragma mark - Life cycle
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteBackground"]];
        _backImage.contentMode = UIViewContentModeScaleToFill;
        _backImage.layer.cornerRadius =5.0;
        _backImage.clipsToBounds = YES;
        _backImage.userInteractionEnabled = YES;
        [self.contentView addSubview:_backImage];
        
        _contentText = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentText setTextColor:[UIColor blackColor]];
        _contentText.numberOfLines =0;
        _contentText.textAlignment = NSTextAlignmentCenter;
        [_backImage addSubview:_contentText];
        
        _statisticsView = [[StatisticsFrameView alloc] initWithFrame:CGRectMake(0, 260, 312, 60) style:SNStatisticsStyleTransparent];
        _wowButton = _statisticsView.surprisedButton;
        [_backImage addSubview:_statisticsView];
        
        self.contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0.4);
        self.contentView.layer.shadowOpacity = 0.20;
        
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
    [self.backImage setFrame:self.contentView.bounds];
    [self.contentText setFrame:[self _contentBigTextFrame]];
    [self.statisticsView setFrame:[self _statisticsViewFrame]];
}

//Content
static CGFloat const C_LEFT_MARGIN = 10.0;
static CGFloat const C_UPPER_MARGIN =10.0;
//Content view
static CGFloat const CELL_LEFT_MARGIN = 7.0;
static CGFloat const CELL_UPPER_MARGIN = 7.0;

-(CGRect)_contentViewFrame{
    return CGRectMake(CELL_LEFT_MARGIN, CELL_UPPER_MARGIN, self.bounds.size.width - 2*CELL_LEFT_MARGIN, self.bounds.size.height-2*CELL_UPPER_MARGIN);
}
-(CGRect)_contentBigTextFrame{
    CGSize textHeight = [self _contentBigTextHeight];
    return CGRectMake(C_LEFT_MARGIN,(self.contentView.bounds.size.height-textHeight.height)/2.0f,self.contentView.bounds.size.width -2*(C_LEFT_MARGIN-1), textHeight.height);
}
-(CGSize)_contentBigTextHeight{
    NSString* text =self.post.content?self.contentText.text:@"s";
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    //paragraphStyle.lineHeightMultiple = 1.3;
    return [text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width -2*C_LEFT_MARGIN, self.contentView.bounds.size.height-2*C_UPPER_MARGIN) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.contentText.font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    
//    NSAttributedString* text = self.contentText.attributedText;
//    return ceilf(CGRectGetHeight([text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 2*C_LEFT_MARGIN, self.contentView.bounds.size.height - 2*C_UPPER_MARGIN) options:NSStringDrawingUsesDeviceMetrics context:nil]))+1;
}

-(CGRect)_statisticsViewFrame{
    return CGRectMake(0, self.contentView.bounds.size.height - 52, self.contentView.bounds.size.width, 52);
}

#pragma mark - Custom Accessors

-(void)setPost:(Post *)post{
    _post=post;
    
    //content
    self.contentText.font = [UIFont systemFontOfSize:[self contentTextSize]];
    
    NSString* contentText = [NSString stringWithFormat:@"\"%@\"",post.content];
    NSRange startRange = NSMakeRange(0, 1);
    NSRange endRange = NSMakeRange(contentText.length-1, 1);
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithString:contentText];
    [attributeContent addAttribute:NSForegroundColorAttributeName value:[UIColor appMainColor] range:startRange];
    [attributeContent addAttribute:NSForegroundColorAttributeName value:[UIColor appMainColor] range:endRange];
    self.contentText.attributedText = attributeContent;
    
    self.statisticsView.surprised = self.post.like;
    self.statisticsView.distance = self.post.distance;
    self.statisticsView.creationDate = self.post.creationDate;
    self.statisticsView.numberOfComments = self.post.numComment;
    self.statisticsView.numberOfSurprised = self.post.rate;
}

#pragma mark - Helpers

-(CGFloat)contentTextSize{
    if (self.post.content.length <=25) {
        return 40.0;
    }else if(self.post.content.length <=80){
        return 32.0;
    }else if(self.post.content.length <= 130){
        return 27.0;
    }else if(self.post.content.length <= 175){
        return 22.0;
    }else{
        return 20.0;
    }
}

@end
