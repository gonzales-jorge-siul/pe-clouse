//
//  UIColor+SNColors.m
//  SNApp
//
//  Created by Force Close on 7/13/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "UIColor+SNColors.h"

@implementation UIColor (SNColors)

+(UIColor *)gray200Color{
    
    static UIColor *color;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:238.0f / 255.0f
                                green:238.0f / 255.0f
                                 blue:238.0f / 255.0f
                                alpha:1.0f];
    });
    
    return color;
}

+(UIColor *)gray500Color{
    
    static UIColor *color;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:158.0f / 255.0f
                                green:158.0f / 255.0f
                                 blue:158.0f / 255.0f
                                alpha:1.0f];
    });
    
    return color;
}


+(UIColor *)gray800Color{
    
    static UIColor *color;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:66.0f / 255.0f
                                green:66.0f / 255.0f
                                 blue:66.0f / 255.0f
                                alpha:1.0f];
    });
    
    return color;
}


+(UIColor *)blueA400Color{
   
    static UIColor *color;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:41.0 / 255.0f
                                green:121.0 / 255.0f
                                 blue:255.0 / 255.0f
                                alpha:1.0];
    });
    
    return color;
}

+(UIColor *)appMainColor{
    
    static UIColor *color;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:00.0  / 255.0f
                                green:183.0 / 255.0f
                                 blue:178.0 / 255.0f
                                alpha:1.0];
    });
    
    return color;
}

@end
