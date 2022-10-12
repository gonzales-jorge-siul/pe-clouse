//
//  SNConstans.h
//  SNApp
//
//  Created by Force Close on 6/19/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNConstans : NSObject

extern NSString* const SNMainStoryboardName;
extern NSString* const SNPostStoryboardIdentifier;
extern NSString* const SNChatStoryboardIdentifier;
extern NSString* const SNSettingsStoryboardIdentifier;

extern NSString* const SNSERVICES_ERROR_DOMAIN;

typedef NS_ENUM(NSInteger, SNServicesErrorCodes) {
    SNNoInternet = 1,
    SNNoServer = 2
};

extern const int SN_POST_MAX_NUMBER_LETTERS;

@end
