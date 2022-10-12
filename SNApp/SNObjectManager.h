//
//  SNObjectManager.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//
#import <RKCoreData.h>
#import <RestKit/RestKit.h>
#import "RKObjectManager.h"


@interface SNObjectManager : RKObjectManager

+(instancetype)sharedManager;


@end
