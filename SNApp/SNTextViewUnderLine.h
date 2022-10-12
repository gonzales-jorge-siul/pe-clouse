//
//  SNTextViewUnderLine.h
//  SNApp
//
//  Created by Force Close on 7/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTextViewUnderLine : UIView

@property(nonatomic,strong)NSString* placeholder;
@property(nonatomic,strong)NSString* text;

@property(nonatomic,strong)NSNumber* maximumLetters;

@property(nonatomic,strong)UIFont* font;

@end
