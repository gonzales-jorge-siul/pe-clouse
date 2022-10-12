//
//  SNDate.h
//  SNApp
//
//  Created by Force Close on 10/30/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDate : NSDate

+(instancetype)sharedInstance;

+(NSDate*)serverDate;

+(NSDate*)dateWithTimeIntervalSinceServerDate:(NSTimeInterval)secs;

-(void)syncServerDate;

@end
