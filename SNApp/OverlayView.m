//
//  OverlayView.m
//  SNApp
//
//  Created by Force Close on 6/25/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "OverlayView.h"

@interface OverlayView ()

@end

@implementation OverlayView

#pragma mark - Life cycle

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        
        //Background
        CGFloat barHeight = (frame.size.width/3) / 2;
//        CGFloat barHeight = 66;
        
        UIGraphicsBeginImageContext(frame.size);
        [[UIColor colorWithWhite:0 alpha:1.0f] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, frame.size.width, barHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, frame.size.width + barHeight, frame.size.width, frame.size.height - frame.size.width - barHeight), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
       
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:frame];
        overlayImageView.image = overlayImage;
        overlayImageView.tag = 10;
        [self addSubview:overlayImageView];
        
        //Back button
        _backbutton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_backbutton setImage:[UIImage imageNamed:@"backArrowIcon"] forState:UIControlStateNormal];
        [self addSubview:_backbutton];
        
        //Shutter
        _shutterButton =[[UIButton alloc] initWithFrame:CGRectZero];
        [[_shutterButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [_shutterButton setImage:[UIImage imageNamed:@"shutterIcon"] forState:UIControlStateNormal];
        _shutterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _shutterButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [self addSubview:_shutterButton];
        
        //Flash mode
        _flashModeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_flashModeButton setImage:[UIImage imageNamed:@"flashModeOnIcon"] forState:UIControlStateNormal];
        [self addSubview:_flashModeButton];
        
        //Camera
        _cameraButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_cameraButton setImage:[UIImage imageNamed:@"switchCameraIcon"] forState:UIControlStateNormal];
        [self addSubview:_cameraButton];
        
        //Took picture
        _tookPicture = [[UIImageView alloc] initWithFrame:frame];
        _tookPicture.backgroundColor = [UIColor blackColor];
        _tookPicture.contentMode = UIViewContentModeScaleAspectFit;
        _tookPicture.alpha = 0.f;
        [self addSubview:_tookPicture];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.shutterButton setFrame:[self _shutterFrame]];
    [self.flashModeButton setFrame:[self _flashModeFrame]];
    [self.cameraButton setFrame:[self _cameraFrame]];
    [self.backbutton setFrame:[self _backButtonFrame]];
    [self.tookPicture setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width*4/3)];
}

#pragma mark - Constans

//Flas mode
CGFloat const FLASH_MODE_HEIGHT =33.0;
CGFloat const FLASH_MODE_WIDHT = 33.0;
//CGFloat const FLASH_MODE_LEFT_MARGIN = 12.0;
CGFloat const FLASH_MODE_UPPER_MARGIN = 12.0;

//Camera
CGFloat const CAMERA_HEIGHT =33.0;
CGFloat const CAMERA_WIDHT = 33.0;
//CGFloat const CAMERA_LEFT_MARGIN = 8.0;
CGFloat const CAMERA_UPPER_MARGIN = 12.0;

//Back button
CGFloat const BACK_BUTTON_HEIGHT = 44.0;
CGFloat const BACK_BUTTON_WIDTH = 44.0;

//Shutter
CGFloat const SHUTTER_HEIGHT = 75;
CGFloat const SHUTTER_WIDHT =75;

#pragma mark - Helpers layout

-(CGRect)_shutterFrame{
    return CGRectMake((self.bounds.size.width - SHUTTER_WIDHT)/2.0f,((1.25)*self.bounds.size.width + self.bounds.size.height - SHUTTER_HEIGHT)/2.0f,SHUTTER_WIDHT ,SHUTTER_HEIGHT);
}

-(CGRect)_flashModeFrame{
    return CGRectMake(0,(1.25)*self.bounds.size.width + FLASH_MODE_UPPER_MARGIN ,FLASH_MODE_WIDHT,FLASH_MODE_HEIGHT);
}

-(CGRect)_cameraFrame{
    return CGRectMake(self.bounds.size.width-CAMERA_WIDHT,(1.25)*self.bounds.size.width + CAMERA_UPPER_MARGIN ,CAMERA_WIDHT,CAMERA_HEIGHT);
}

-(CGRect)_backButtonFrame{
    return CGRectMake(0, 0, BACK_BUTTON_WIDTH, self.bounds.size.width/6.0f);
}

-(void)setImageCustom:(UIImage *)image{
    [self.tookPicture setImage:image];
    self.tookPicture.alpha = 1.0f;
    [self bringSubviewToFront:[self viewWithTag:10]];
}

@end

