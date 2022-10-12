//
//  SNServer.h
//  SNApp
//
//  Created by Force Close on 10/31/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface SNServer : NSObject

@property (nonatomic,strong) NSDate* date;

+(RKObjectMapping*)serverMapping;

@end
