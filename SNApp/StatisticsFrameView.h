//
//  StatisticsFrameView.h
//  SNApp
//
//  Created by Force Close on 7/30/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsFrameView : UIView

typedef NS_ENUM(NSInteger, SNStatisticsStyle) {
    SNStatisticsStyleTransparent=0,
    SNStatisticsStyleDarkTransluce=1,
    SNStatisticsStyleAppColorTransluce=2
};

-(instancetype)initWithFrame:(CGRect)frame style:(SNStatisticsStyle)style;

@property(nonatomic,strong)NSDate* creationDate;
//@property(nonatomic,strong)NSDate* lastActivityDate;
@property(nonatomic,strong)NSNumber* numberOfComments;
@property(nonatomic,strong)NSNumber* numberOfSurprised;
@property(nonatomic,strong)NSNumber* surprised;
@property(nonatomic)SNStatisticsStyle style;
@property(nonatomic,strong)NSNumber* distance;

@property(nonatomic,strong)UIButton* surprisedButton;

@end
