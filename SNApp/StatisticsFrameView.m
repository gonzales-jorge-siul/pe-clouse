//
//  StatisticsFrameView.m
//  SNApp
//
//  Created by Force Close on 7/30/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "StatisticsFrameView.h"
#import "UIColor+SNColors.h"
#import "SNDate.h"

@interface StatisticsFrameView ()

@property(nonatomic,strong)UIImageView* leftTimeView;
@property(nonatomic,strong)UILabel* leftTimeLabel;

@property(nonatomic,strong)UIImageView* numberOfCommentsView;
@property(nonatomic,strong)UILabel* numberOfCommentsLabel;

@property(nonatomic,strong)UIImageView* numberOfSurprisedView;
@property(nonatomic,strong)UILabel* numberOfSurprisedLabel;

//@property(nonatomic,strong)UILabel* lastActivityDateLabel;
@property(nonatomic,strong)UILabel* distanceLabel;

@end

@implementation StatisticsFrameView

#pragma mark - Life cycle

-(instancetype)initWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame style:SNStatisticsStyleTransparent];
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(SNStatisticsStyle)style{
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        
//        _lastActivityDateLabel = [[UILabel alloc] initWithFrame:[self _lastActivityDateLabelFrame:frame]];
//        _lastActivityDateLabel.textColor = [UIColor appMainColor];
//        _lastActivityDateLabel.font = [StatisticsFrameView fontDate];
//        _lastActivityDateLabel.numberOfLines = 1;
//        [self addSubview:_lastActivityDateLabel];
        
        _distanceLabel = [[UILabel alloc] initWithFrame:[self _distanceLabelFrame:frame]];
        _distanceLabel.textColor = [UIColor appMainColor];
        _distanceLabel.font = [StatisticsFrameView fontDate];
        _distanceLabel.numberOfLines = 1;
        [self addSubview:_distanceLabel];
        
        _leftTimeView = [[UIImageView alloc] initWithFrame:[self _leftTimeViewFrame:frame]];
        _leftTimeView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_leftTimeView];
        
        _leftTimeLabel = [[UILabel alloc] initWithFrame:[self _leftTimeLabelFrame:frame]];
        _leftTimeLabel.font = [StatisticsFrameView fontNumbers];
        _leftTimeLabel.numberOfLines = 1;
        [self addSubview:_leftTimeLabel];
        
        _numberOfCommentsView = [[UIImageView alloc] initWithFrame:[self _numberOfCommentsViewFrame:frame]];
        _numberOfCommentsView.image = [[UIImage imageNamed:@"numberOfCommentsPostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _numberOfCommentsView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_numberOfCommentsView];
        
        _numberOfCommentsLabel = [[UILabel alloc] initWithFrame:[self _numberOfCommentsLabelFrame:frame]];
        _numberOfCommentsLabel.font = [StatisticsFrameView fontNumbers];
        _numberOfCommentsLabel.numberOfLines =1;
        [self addSubview:_numberOfCommentsLabel];
        
        _numberOfSurprisedView = [[UIImageView alloc] initWithFrame:[self _numberOfSurprisedViewFrame:frame]];
        _numberOfSurprisedView.image = [[UIImage imageNamed:@"numberOfSurprisedPostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _numberOfSurprisedView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_numberOfSurprisedView];
        
        _numberOfSurprisedLabel = [[UILabel alloc] initWithFrame:[self _numberOfSurprisedLabelFrame:frame]];
        _numberOfSurprisedLabel.font = [StatisticsFrameView fontNumbers];
        _numberOfSurprisedLabel.numberOfLines = 1;
        [self addSubview:_numberOfSurprisedLabel];
        
        _surprisedButton = [[UIButton alloc] initWithFrame:[self _surprisedButtonFrame:frame]];
        _surprisedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _surprisedButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentFill;
        [self addSubview:_surprisedButton];
        
        switch (style) {
            case SNStatisticsStyleTransparent:
                self.backgroundColor = [UIColor clearColor];
                _leftTimeLabel.textColor = [UIColor grayColor];
                _leftTimeView.tintColor = [UIColor grayColor];
                _numberOfCommentsLabel.textColor = [UIColor grayColor];
                _numberOfCommentsView.tintColor = [UIColor grayColor];
                _numberOfSurprisedLabel.textColor = [UIColor grayColor];
                _numberOfSurprisedView.tintColor = [UIColor grayColor];
                _surprisedButton.tintColor = [UIColor grayColor];
                [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalGrayIcon"] forState:UIControlStateNormal];
                break;
            case SNStatisticsStyleDarkTransluce:
                self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
                _leftTimeLabel.textColor = [UIColor whiteColor];
                _leftTimeView.tintColor = [UIColor whiteColor];
                _numberOfCommentsLabel.textColor = [UIColor whiteColor];
                _numberOfCommentsView.tintColor = [UIColor whiteColor];
                _numberOfSurprisedLabel.textColor = [UIColor whiteColor];
                _numberOfSurprisedView.tintColor = [UIColor whiteColor];
                _surprisedButton.tintColor = [UIColor whiteColor];
                [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
                break;
            case SNStatisticsStyleAppColorTransluce:
                self.backgroundColor = [[UIColor appMainColor] colorWithAlphaComponent:0.7];
//                _lastActivityDateLabel.textColor = [UIColor whiteColor];
                _distanceLabel.textColor = [UIColor whiteColor];
                _leftTimeLabel.textColor = [UIColor whiteColor];
                _leftTimeView.tintColor = [UIColor whiteColor];
                _numberOfCommentsLabel.textColor = [UIColor whiteColor];
                _numberOfCommentsView.tintColor = [UIColor whiteColor];
                _numberOfSurprisedLabel.textColor = [UIColor whiteColor];
                _numberOfSurprisedView.tintColor = [UIColor whiteColor];
                _surprisedButton.tintColor = [UIColor whiteColor];
                [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
                break;
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.leftTimeView setFrame:[self _leftTimeViewFrame:self.bounds]];
    [self.leftTimeLabel setFrame:[self _leftTimeLabelFrame:self.bounds]];
    [self.numberOfCommentsView setFrame:[self _numberOfCommentsViewFrame:self.bounds]];
    [self.numberOfCommentsLabel setFrame:[self _numberOfCommentsLabelFrame:self.bounds]];
    [self.numberOfSurprisedView setFrame:[self _numberOfSurprisedViewFrame:self.bounds]];
    [self.numberOfSurprisedLabel setFrame:[self _numberOfSurprisedLabelFrame:self.bounds]];
//    [self.lastActivityDateLabel setFrame:[self _lastActivityDateLabelFrame:self.bounds]];
    [self.distanceLabel setFrame:[self _distanceLabelFrame:self.bounds]];
    [self.surprisedButton setFrame:[self _surprisedButtonFrame:self.bounds]];
}

#pragma mark - Helpers layout

//Last activity
CGFloat const LATERAL_MARGIN_LAST_ACTIVITY_SNS= 7.0;
CGFloat const BOTTOM_MARGIN_LAST_ACTIVITY_SNS= 4.0;

//Left time view
CGFloat const LATERAL_MARGIN_LEFT_TIME_VIEW_SNS= 6.0;

//Number of comments view
CGFloat const LATERAL_MARGIN_NUMBER_OF_COMMENTS_VIEW_SNS= 9.0;

//Number of surprised view
CGFloat const LATERAL_MARGIN_NUMBER_OF_SURPRISED_VIEW_SNS= 9.0;

//Numbers
CGFloat const LATERAL_MARGIN_NUMBERS_SNS =2.0;
CGFloat const BOTTOM_MARGIN_NUMBERS_SNS= 6.0;

CGFloat const WIDTH_PERCENT_NUMBER_SNS = 0.2f;

//Surprised button
CGFloat const WIDTH_SURPRISED_BUTTON_SNS= 40.0;
CGFloat const HEIGHT_SURPRISED_BUTTON_SNS= 40.0;
CGFloat const LATERAL_MARGIN_SURPRISED_BUTTON_SNS= 6.0;
CGFloat const BOTTOM_MARGIN_SURPRISED_BUTTON_SNS= 6.0;

-(CGRect)_lastActivityDateLabelFrame:(CGRect)frame{
    return CGRectMake(LATERAL_MARGIN_LAST_ACTIVITY_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS -BOTTOM_MARGIN_LAST_ACTIVITY_SNS - [StatisticsFrameView fontDate].lineHeight, frame.size.width , [StatisticsFrameView fontDate].lineHeight);
}

-(CGRect)_distanceLabelFrame:(CGRect)frame{
    return CGRectMake(LATERAL_MARGIN_LAST_ACTIVITY_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS -BOTTOM_MARGIN_LAST_ACTIVITY_SNS - [StatisticsFrameView fontDate].lineHeight, frame.size.width , [StatisticsFrameView fontDate].lineHeight);
}

//-(CGRect)_leftTimeViewFrame:(CGRect)frame{
//    return CGRectMake(LATERAL_MARGIN_LEFT_TIME_VIEW_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
//}
//
//-(CGRect)_leftTimeLabelFrame:(CGRect)frame{
//    CGRect imageViewFrame = [self _leftTimeViewFrame:frame];
//    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x, imageViewFrame.origin.y, frame.size.width*(WIDTH_PERCENT_NUMBER_SNS)-imageViewFrame.size.width, imageViewFrame.size.height);
//}
//
//-(CGRect)_numberOfCommentsViewFrame:(CGRect)frame{
//    return CGRectMake(frame.size.width*(WIDTH_PERCENT_NUMBER_SNS), frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
//}
//
//-(CGRect)_numberOfCommentsLabelFrame:(CGRect)frame{
//    CGRect imageViewFrame = [self _numberOfCommentsViewFrame:frame];
//    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x + LATERAL_MARGIN_NUMBERS_SNS, imageViewFrame.origin.y, frame.size.width*(WIDTH_PERCENT_NUMBER_SNS)-imageViewFrame.size.width, imageViewFrame.size.height);
//}
//
//-(CGRect)_numberOfSurprisedViewFrame:(CGRect)frame{
//    return CGRectMake(frame.size.width*(2*WIDTH_PERCENT_NUMBER_SNS), frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
//}
//
//-(CGRect)_numberOfSurprisedLabelFrame:(CGRect)frame{
//    CGRect imageViewFrame = [self _numberOfSurprisedViewFrame:frame];
//    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x +LATERAL_MARGIN_NUMBERS_SNS, imageViewFrame.origin.y, frame.size.width*(WIDTH_PERCENT_NUMBER_SNS)-imageViewFrame.size.width, imageViewFrame.size.height);
//}


-(CGRect)_leftTimeViewFrame:(CGRect)frame{
    return CGRectMake(LATERAL_MARGIN_LEFT_TIME_VIEW_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
}

-(CGRect)_leftTimeLabelFrame:(CGRect)frame{
    CGRect imageViewFrame = [self _leftTimeViewFrame:frame];
    CGSize textSize = CGSizeZero;
    if (_leftTimeLabel.text) {
        textSize = [_leftTimeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_leftTimeLabel.font} context:nil].size;
    }
    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x, imageViewFrame.origin.y, textSize.width , imageViewFrame.size.height);
}

-(CGRect)_numberOfCommentsViewFrame:(CGRect)frame{
    CGRect leftTimeLabelFrame = _leftTimeLabel.frame;
    return CGRectMake(leftTimeLabelFrame.size.width + leftTimeLabelFrame.origin.x + LATERAL_MARGIN_NUMBER_OF_COMMENTS_VIEW_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
}

-(CGRect)_numberOfCommentsLabelFrame:(CGRect)frame{
    CGRect imageViewFrame = [self _numberOfCommentsViewFrame:frame];
    CGSize textSize = CGSizeZero;
    if (_numberOfCommentsLabel.text) {
        textSize = [_numberOfCommentsLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_numberOfCommentsLabel.font} context:nil].size;
    }
    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x + LATERAL_MARGIN_NUMBERS_SNS, imageViewFrame.origin.y, textSize.width, imageViewFrame.size.height);
}

-(CGRect)_numberOfSurprisedViewFrame:(CGRect)frame{
    CGRect numberOfCommentsLabelFrame = _numberOfCommentsLabel.frame;
    return CGRectMake(numberOfCommentsLabelFrame.size.width + numberOfCommentsLabelFrame.origin.x + LATERAL_MARGIN_NUMBER_OF_SURPRISED_VIEW_SNS, frame.size.height - [StatisticsFrameView fontNumbers].lineHeight -BOTTOM_MARGIN_NUMBERS_SNS, [StatisticsFrameView fontNumbers].lineHeight, [StatisticsFrameView fontNumbers].lineHeight);
}

-(CGRect)_numberOfSurprisedLabelFrame:(CGRect)frame{
    CGRect imageViewFrame = [self _numberOfSurprisedViewFrame:frame];
    CGSize textSize = CGSizeZero;
    if (_numberOfSurprisedLabel.text) {
        textSize = [_numberOfSurprisedLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_numberOfSurprisedLabel.font} context:nil].size;
    }
    return CGRectMake(imageViewFrame.size.width + imageViewFrame.origin.x +LATERAL_MARGIN_NUMBERS_SNS, imageViewFrame.origin.y, textSize.width, imageViewFrame.size.height);
}


-(CGRect)_surprisedButtonFrame:(CGRect)frame{
    return CGRectMake(frame.size.width - LATERAL_MARGIN_SURPRISED_BUTTON_SNS - WIDTH_SURPRISED_BUTTON_SNS, frame.size.height-BOTTOM_MARGIN_SURPRISED_BUTTON_SNS -HEIGHT_SURPRISED_BUTTON_SNS, WIDTH_SURPRISED_BUTTON_SNS, HEIGHT_SURPRISED_BUTTON_SNS);
}

+(UIFont*)fontNumbers{
    return [UIFont systemFontOfSize:16.0];
}

+(UIFont*)fontDate{
    return [UIFont systemFontOfSize:17.0];
}

#pragma mark - Custom accessors

-(void)setCreationDate:(NSDate *)creationDate{
    _creationDate = creationDate;
    NSUInteger hoursLeft = [self hoursLeftOfDate:creationDate duration:24];
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)hoursLeft];
    self.leftTimeView.image = [self imageForHoursLeft:hoursLeft duration:24];
//    [self.leftTimeLabel setNeedsDisplay];
//    [self.leftTimeView setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setNumberOfComments:(NSNumber *)numberOfComments{
    _numberOfComments = numberOfComments;
    self.numberOfCommentsLabel.text = [self textForNumber:numberOfComments];
//    [self.numberOfCommentsLabel setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setNumberOfSurprised:(NSNumber *)numberOfSurprised{
    _numberOfSurprised = numberOfSurprised;
    self.numberOfSurprisedLabel.text = [self textForNumber:numberOfSurprised];
//    [self.numberOfSurprisedLabel setNeedsDisplay];
    [self setNeedsLayout];
}

//-(void)setLastActivityDate:(NSDate *)lastActivityDate{
//    _lastActivityDate = lastActivityDate;
//    self.lastActivityDateLabel.text = [self textForDate:lastActivityDate];
////    [self.lastActivityDateLabel setNeedsDisplay];
//    [self setNeedsLayout];
//}

-(void)setDistance:(NSNumber *)distance{
    _distance = distance;
    
    self.distanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"statistics.distance.%d meters", @"{distance} meters"),[self.distance intValue]];
    [self setNeedsLayout];
}

-(void)setSurprised:(NSNumber *)surprised{
    _surprised = surprised;
    if ([self.surprised boolValue]) {
        [self.surprisedButton setImage:[UIImage imageNamed:@"surprisedStatePressedIcon"] forState:UIControlStateNormal];
    }else{
        switch (self.style) {
            case SNStatisticsStyleTransparent:
                [self.surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalGrayIcon"] forState:UIControlStateNormal];
                break;
            default:
                [self.surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
                break;
        }
    }
//    [self.surprisedButton setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setStyle:(SNStatisticsStyle)style{
    _style = style;
    switch (style) {
        case SNStatisticsStyleDarkTransluce:
            self.backgroundColor =[UIColor colorWithWhite:0.0 alpha:0.7];
            self.leftTimeLabel.textColor = [UIColor whiteColor];
            self.leftTimeView.tintColor = [UIColor whiteColor];
            self.numberOfCommentsLabel.textColor = [UIColor whiteColor];
            self.numberOfCommentsView.tintColor = [UIColor whiteColor];
            self.numberOfSurprisedLabel.textColor = [UIColor whiteColor];
            self.numberOfSurprisedView.tintColor = [UIColor whiteColor];
            self.surprisedButton.tintColor = [UIColor whiteColor];
            [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalGrayIcon"] forState:UIControlStateNormal];
            break;
        case SNStatisticsStyleTransparent:
            self.backgroundColor = [UIColor clearColor];
            self.leftTimeLabel.textColor = [UIColor grayColor];
            self.leftTimeView.tintColor = [UIColor grayColor];
            self.numberOfCommentsLabel.textColor = [UIColor grayColor];
            self.numberOfCommentsView.tintColor = [UIColor grayColor];
            self.numberOfSurprisedLabel.textColor = [UIColor grayColor];
            self.numberOfSurprisedView.tintColor = [UIColor grayColor];
            self.surprisedButton.tintColor = [UIColor grayColor];
            [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
            break;
        case SNStatisticsStyleAppColorTransluce:
            self.backgroundColor = [[UIColor appMainColor] colorWithAlphaComponent:0.7];
//            _lastActivityDateLabel.textColor = [UIColor whiteColor];
            _distanceLabel.textColor = [UIColor whiteColor];
            _leftTimeLabel.textColor = [UIColor whiteColor];
            _leftTimeView.tintColor = [UIColor whiteColor];
            _numberOfCommentsLabel.textColor = [UIColor whiteColor];
            _numberOfCommentsView.tintColor = [UIColor whiteColor];
            _numberOfSurprisedLabel.textColor = [UIColor whiteColor];
            _numberOfSurprisedView.tintColor = [UIColor whiteColor];
            _surprisedButton.tintColor = [UIColor whiteColor];
            [_surprisedButton setImage:[UIImage imageNamed:@"surprisedStateNormalIcon"] forState:UIControlStateNormal];
            break;
    }
    [self setNeedsLayout];
}

#pragma Helpers

-(NSUInteger)hoursLeftOfDate:(NSDate*)creationDate duration:(NSUInteger)hoursInterval{
    NSDate* now = [SNDate serverDate];
    
    NSTimeInterval interval = [now timeIntervalSinceDate:creationDate];
//    Add four hours
//    interval += 14400.f;
    interval = interval/3600.0f;
    
    CGFloat hoursLeft = hoursInterval - interval;
    
    if (hoursLeft<0 || hoursLeft>hoursInterval) {
        return 1;
    }else{
        return roundf(hoursLeft)>0?round(hoursLeft):1;
    }
}

-(UIImage*)imageForHoursLeft:(NSUInteger)hoursLeft duration:(NSUInteger)hoursInterval{
    if (hoursLeft<=hoursInterval*(1/8.0f)) {
        return [[UIImage imageNamed:@"3hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(2/8.0f)){
        return [[UIImage imageNamed:@"6hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(3/8.0f)){
        return [[UIImage imageNamed:@"9hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(4/8.0f)){
        return [[UIImage imageNamed:@"12hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(5/8.0f)){
        return [[UIImage imageNamed:@"15hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(6/8.0f)){
        return [[UIImage imageNamed:@"18hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval*(7/8.0f)){
        return [[UIImage imageNamed:@"21hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if (hoursLeft<=hoursInterval){
        return [[UIImage imageNamed:@"24hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else{
        return [[UIImage imageNamed:@"3hoursLeftTimePostIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

-(NSString*)textForNumber:(NSNumber*)aNumber{
    NSUInteger number = [aNumber integerValue]>0?[aNumber integerValue]:0;
    if (number<1000) {
        return [NSString stringWithFormat:@"%lu",(unsigned long)number];
    }else if (number<10000){
        CGFloat newNumber=roundf(number/100.0f)/10.0f;
        return [NSString stringWithFormat:@"%.1fK",newNumber];
    }else if (number<100000){
        NSUInteger newNumber =roundf(number/1000.0f);
        return [NSString stringWithFormat:@"%luK",(unsigned long)newNumber];
    }else if (number<1000000){
        CGFloat newNumber = roundf(number/100000.0f)/10.0f;
        return [NSString stringWithFormat:@"%.1fM",newNumber];
    }else{
        NSUInteger newNumber = roundf(number/1000000.0f);
        return [NSString stringWithFormat:@"%luM",(unsigned long)newNumber];
    }
}

-(NSString*)textForDate:(NSDate*)date{
    double secondsInPost = [date timeIntervalSinceNow];
    //sync whit local hour
    secondsInPost -=14400;
    if (secondsInPost<0) {
        secondsInPost = -1*secondsInPost;
        if (secondsInPost<60) {
            int seconds = secondsInPost;
            return [NSString stringWithFormat:NSLocalizedString(@"statistics.update-time.%d seconds ago", @"{number of seconds} seconds ago"),seconds];
        }else if(secondsInPost<3600){
            int minutes = secondsInPost/60;
            return [NSString stringWithFormat:NSLocalizedString(@"statistics.update-time.%d minutes ago", @"{number of minutes} minutes ago"),minutes];
        }else if(secondsInPost<86400){
            int hours = secondsInPost/3600;
            return [NSString stringWithFormat:NSLocalizedString(@"statistics.update-time.%d hours ago", @"{number of hours} hours ago"),hours];
        }else if (secondsInPost<604800){
            int days = secondsInPost/86400;
            return [NSString stringWithFormat:NSLocalizedString(@"statistics.update-time.%d days ago", @"{number of days} days ago"),days];
        }else{
            int weeks = secondsInPost/604800;
            return [NSString stringWithFormat:NSLocalizedString(@"statistics.update-time.%d weeks ago", @"{number of weeks} weeks ago"),weeks];
        }
    }else{
        return NSLocalizedString(@"app.general.At future", @"just for test");
    }
}

@end
