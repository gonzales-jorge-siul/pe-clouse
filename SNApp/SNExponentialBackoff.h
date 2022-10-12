//
//  SNExponentialBackoff.h
//  SNApp
//
//  Created by Force Close on 6/23/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNExponentialBackoff : NSObject


@property(nonatomic,strong) BOOL(^handlertime)(BOOL lastTime);
@property(atomic,strong) NSNumber *maxNumberOfRepetitions;

@property(nonatomic,getter=isStart,readonly) BOOL start;
@property(nonatomic,getter=isPause,readonly) BOOL pause;
@property(nonatomic,getter=isResume,readonly) BOOL resume;
@property(nonatomic,getter=isReset,readonly) BOOL reset;
@property(nonatomic,getter=isStop,readonly) BOOL stop;
@property(nonatomic,getter=isLastTime,readonly) BOOL lastTime;

-(instancetype)initWithMaxNumberOfRepetitions:(NSNumber*)maxNumber;
-(instancetype)initWithMaxNumberOfRepetitions:(NSNumber*)maxNumber multiplier:(double)multiplier;

-(void)start;
-(void)pause;
-(void)resume;
-(void)reset;
-(void)stop;

@end
