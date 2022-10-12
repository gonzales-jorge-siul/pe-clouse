//
//  AddPostView.h
//  SNApp
//
//  Created by Force Close on 6/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTextViewUnderLine.h"

@interface AddPostView : UIView

@property (nonatomic,strong) UIButton* deletePhoto;
@property (nonatomic,strong) UIButton* cameraButton;
@property (nonatomic,strong) UIImageView* photoView;
@property (nonatomic,strong) SNTextViewUnderLine* textView;

@end
