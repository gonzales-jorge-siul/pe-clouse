//
//  SNExponentialBackoff.m
//  SNApp
//
//  Created by Force Close on 6/23/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNExponentialBackoff.h"

@interface SNExponentialBackoff ()

@property NSTimer* timer;
@property BOOL oldStartValue;

@property(nonatomic,getter=isStart) BOOL start;
@property(nonatomic,getter=isPause) BOOL pause;
@property(nonatomic,getter=isResume) BOOL resume;
@property(nonatomic,getter=isReset) BOOL reset;
@property(nonatomic,getter=isStop) BOOL stop;
@property(nonatomic,getter=isLastTime) BOOL lastTime;

@end

@implementation SNExponentialBackoff

double _timeInterval;
int _numberOfRepetitions;
double _multiplier;

const double MIN_ELAPSED_TIME= 1;
const double MAX_ELAPSED_TIME=60.0;
const int MAX_NUMBER_OF_REPETITIONS=8;
const double MULTIPLIER_STD=1.5;

-(instancetype)init{
   return [self initWithMaxNumberOfRepetitions:[NSNumber numberWithInt:MAX_NUMBER_OF_REPETITIONS] multiplier:MULTIPLIER_STD];
}

-(instancetype)initWithMaxNumberOfRepetitions:(NSNumber *)maxNumber{
    return [self initWithMaxNumberOfRepetitions:maxNumber multiplier:MULTIPLIER_STD];
}

-(instancetype)initWithMaxNumberOfRepetitions:(NSNumber*)maxNumber multiplier:(double)multiplier{
    self = [super init];
    if (self) {
        _timeInterval = MIN_ELAPSED_TIME;
        _numberOfRepetitions = 0;
        _maxNumberOfRepetitions = maxNumber;
        _multiplier=multiplier;
        self.oldStartValue =NO;
    }
    return self;
}

-(void)startWithTimer:(NSTimer *)timer{
    if (_numberOfRepetitions+1<[[self maxNumberOfRepetitions] intValue]){
        self.lastTime =NO;
        BOOL isSuccessful = self.handlertime(NO);
        if (!isSuccessful && !self.isPause && !self.isStop) {
            _timeInterval = _timeInterval >= MIN_ELAPSED_TIME ? _timeInterval * _multiplier : MIN_ELAPSED_TIME;
            _timeInterval = MIN(MAX_ELAPSED_TIME, _timeInterval);
            _numberOfRepetitions++;
            self.timer=[NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(startWithTimer:) userInfo:nil repeats:NO];
        }else if(isSuccessful){
            self.stop =YES;
        }
    }else if(_numberOfRepetitions+1==[[self maxNumberOfRepetitions] intValue]) {
        self.handlertime(YES);
        self.stop =YES;
        self.lastTime =YES;
    }
}

-(void)setStart:(BOOL)start{
    if (self.oldStartValue != start) {
        self.oldStartValue = start;
        _start=start;
        if (_start) {
            self.reset = YES;
            self.stop = NO;
            self.pause = NO;
            [self.timer invalidate];
            self.timer=[NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(startWithTimer:) userInfo:nil repeats:NO];
        }
    }
}

-(void)setPause:(BOOL)pause{
    _pause =pause;
}

-(void)setResume:(BOOL)resume{
    _resume = resume;
    if (_resume) {
        if (self.timer) {
            NSComparisonResult result=[[self.timer fireDate] compare:[NSDate date]];
            if (result==NSOrderedAscending) {
                _timeInterval = _timeInterval >= MIN_ELAPSED_TIME ? _timeInterval * _multiplier : MIN_ELAPSED_TIME;
                _timeInterval = MIN(MAX_ELAPSED_TIME, _timeInterval);
                _numberOfRepetitions++;
                [self.timer invalidate];
                self.timer=[NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(startWithTimer:) userInfo:nil repeats:NO];
                
                _resume = NO;
            }
        }
    }
}

-(void)setReset:(BOOL)reset{
    _reset = reset;
    if (_reset) {
        _timeInterval = MIN_ELAPSED_TIME;
        _numberOfRepetitions = 0;
        _reset = NO;
    }
}

-(void)setStop:(BOOL)stop{
    _stop =stop;
    if (stop) {
        [self.timer invalidate];
        self.reset = YES;
        self.start = NO;
        self.lastTime =NO;
    }
}

-(void)start{
    self.start = YES;
}
-(void)pause{
    self.pause = YES;
}
-(void)resume{
    self.resume =YES;
}
-(void)reset{
    self.reset =YES;
}
-(void)stop{
    self.stop =YES;
}

@end
