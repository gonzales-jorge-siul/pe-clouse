//
//  OverlayView.h
//  SNApp
//
//  Created by Force Close on 6/25/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView

@property(nonatomic,strong)UIButton* backbutton;
@property(nonatomic,strong)UIButton* shutterButton;
@property(nonatomic,strong)UIButton* flashModeButton;
@property(nonatomic,strong)UIButton* cameraButton;

@property(nonatomic,strong)UIImageView* tookPicture;

-(void)setImageCustom:(UIImage*)image;

@end