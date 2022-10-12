//
//  SNDate.m
//  SNApp
//
//  Created by Force Close on 10/30/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "SNDate.h"
#import "SNAccountResourceManager.h"
#import "SNServer.h"

@interface SNDate ()

@property(nonatomic,strong) NSDate* serverDateSync;
@property(nonatomic,strong) NSDate* serverGMTDate;

@end

@implementation SNDate

+(instancetype)sharedInstance{
    
    static SNDate *__sharedInstance;
    
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken,^{
            
            //Initialization
            __sharedInstance = [[self alloc] init];
            __sharedInstance.serverDateSync = [NSDate dateWithTimeIntervalSinceNow:14400];
            __sharedInstance.serverGMTDate = [NSDate date];
            [__sharedInstance syncServerDate];
            
        });
    
    return __sharedInstance;
}

#pragma mark - Public class methods

+(NSDate *)serverDate{
    
    //Do some stuff to get the correct time
    
    return [[SNDate sharedInstance] serverDateSync];
//    return [NSDate dateWithTimeIntervalSinceNow:0];
}

+(NSDate *)dateWithTimeIntervalSinceServerDate:(NSTimeInterval)secs{
    return [NSDate dateWithTimeIntervalSinceNow:-10];
}

#pragma mark - Public methods

-(void)syncServerDate{
    SNDate* __weak weakSelf = self;
    [[SNAccountResourceManager sharedManager] getServerDateWithBlockOnSuccess:^(SNServer *response) {
        weakSelf.serverDateSync = response.date;
    } failure:nil];
}

@end
