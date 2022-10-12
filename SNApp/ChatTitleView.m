//
//  ChatTitleView.m
//  SNApp
//
//  Created by Force Close on 8/25/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ChatTitleView.h"
#import "UIColor+SNColors.h"

@interface ChatTitleView ()

@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UILabel* lastConnectionLabel;

@end

@implementation ChatTitleView

#pragma mark - Custom accessors

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = self.title;
}

-(void)setUserLastConnection:(UserLastConnection *)userLastConnection{
    _userLastConnection = userLastConnection;
    if (userLastConnection) {
        if ([userLastConnection.isConnect boolValue]) {
            self.lastConnectionLabel.text = NSLocalizedString(@"chatlist.chat.title.connected", nil);
        }else{
            self.lastConnectionLabel.text = [self textForDate:self.userLastConnection.lastConnectionDate];
        }
        [self stateTitleAndDate];
    }else{
        [self stateJustTitle];
    }
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

-(UILabel *)lastConnectionLabel{
    if (!_lastConnectionLabel) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 200, 20)];
        label.numberOfLines = 1;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor gray800Color];
        label.alpha = 1.f;
        [self addSubview:label];
        _lastConnectionLabel = label;
    }
    return _lastConnectionLabel;
}

#pragma mark - Helpers

-(void)stateJustTitle{
    self.lastConnectionLabel.alpha = 0.f;
    self.titleLabel.frame = CGRectMake(0, 0, 200, 44);
    [self.lastConnectionLabel setNeedsDisplay];
    [self.titleLabel setNeedsDisplay];
}

-(void)stateTitleAndDate{
    ChatTitleView* __weak weakSelf =self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.titleLabel.frame = CGRectMake(0, 0, 200, 24);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.lastConnectionLabel.alpha = 1.f;
        }];
    }];
}

-(NSString*)textForDate:(NSDate*)date{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];

    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute ;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    comps.hour -= 4;
    date =[calendar dateFromComponents:comps];
    
    
    unsigned units = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *dateComponents = [calendar components:units fromDate: date];
    NSDateComponents *currentDateComponents = [calendar components:units fromDate: [NSDate date]];
    
    NSDate* dateFromComponents = [calendar dateFromComponents:dateComponents];
    NSDate* currentDateFromComponents = [calendar dateFromComponents:currentDateComponents];
    
    
    
    NSComparisonResult result = [dateFromComponents compare:currentDateFromComponents];
    if (result == NSOrderedAscending) {
        if ([dateComponents year]==[currentDateComponents year] &&[dateComponents month] == [currentDateComponents month] &&
            labs([dateComponents day]-[currentDateComponents day])==1) {
            formatter.dateFormat =@"HH:mm";
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.lastSeen.Last seen yesterdat at %@", @"Last seen yesterday at {date format : HH:mm}"),[formatter stringFromDate:date]];//Yesterday
        }else{
            formatter.dateFormat =@"dd/MM/yy HH:mm";
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.lastSeen.Last seen %@", @"Last seen {date format : dd/MM/yy HH:mm}"),[formatter stringFromDate:date]];
        }
    } else if (result == NSOrderedDescending) {
        formatter.dateFormat =@"dd/MM/yy HH:mm";
        return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.lastSeen.Last seen %@", @"Last seen {date format : dd/MM/yy HH:mm}"),[formatter stringFromDate:date]];
    }  else {
        formatter.dateFormat =@"HH:mm";
        return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.lastSeen.Last seen today at %@", @"Last seen today at {date format : HH:mm}"),[formatter stringFromDate:date]];
    }
}

@end
