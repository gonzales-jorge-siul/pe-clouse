//
//  PostBaseTableViewCell.m
//  SNApp
//
//  Created by Force Close on 7/27/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostBaseTableViewCell.h"
#import "UIColor+SNColors.h"

@implementation PostBaseTableViewCell

-(void)startAnimation{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.contentView.bounds.size.height - [UIFont systemFontOfSize:40.f].lineHeight)/2.f, self.contentView.bounds.size.width, [UIFont systemFontOfSize:40.f].lineHeight)];
    label.font = [UIFont systemFontOfSize:40.f];
    label.text = NSLocalizedString(@"app.general.like", nil);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.alpha = 0.f;
    
    UIView* view = [[UIView alloc] initWithFrame:self.contentView.bounds];
    view.backgroundColor = [UIColor appMainColor];
    view.alpha = 0.f;
    
    [view addSubview:label];
    [self.contentView addSubview:view];
    
    CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim1.fromValue = [NSNumber numberWithFloat:self.contentView.bounds.size.height];
    anim1.toValue = [NSNumber numberWithFloat:0.f];
    anim1.duration = 0.1;
    [view.layer addAnimation:anim1 forKey:@"cornerRadius"];
    
    [UIView animateWithDuration:0.1f animations:^{
        view.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f animations:^{
            label.alpha = 0.99f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.75f animations:^{
                label.alpha = 1.f;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
                [view removeFromSuperview];
            }];
        }];
    }];
}

@end
