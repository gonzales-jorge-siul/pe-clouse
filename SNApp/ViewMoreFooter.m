//
//  ViewMoreFooter.m
//  SNApp
//
//  Created by Force Close on 10/30/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "ViewMoreFooter.h"
#import "UIColor+SNColors.h"

@interface ViewMoreFooter ()

@property (nonatomic,strong) UIView* contentView;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation ViewMoreFooter

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        //ContentView
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.layer.cornerRadius = 5.0;
        _contentView.clipsToBounds = YES;
        
        //see more button
        _seeMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_seeMoreButton setTitle:NSLocalizedString(@"post.footer.View more", nil) forState:UIControlStateNormal];
        [_seeMoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_seeMoreButton setTitleColor:[UIColor gray800Color] forState:UIControlStateHighlighted];
        _seeMoreButton.showsTouchWhenHighlighted = YES;
        [_seeMoreButton setTintColor:[UIColor blackColor]];
        _seeMoreButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        _seeMoreButton.backgroundColor = [UIColor whiteColor];
        
        _seeMoreButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        _seeMoreButton.layer.shadowOffset = CGSizeMake(0, 0.4);
        _seeMoreButton.layer.shadowOpacity = 0.2;
        
        [_seeMoreButton addTarget:self action:@selector(loadState:) forControlEvents:UIControlEventTouchUpInside];
        
        //Activity indicator
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        
        //Relations
        [_contentView addSubview:_seeMoreButton];
        [_contentView addSubview:_activityIndicator];
        [self addSubview:_contentView];
        
        //self
        self.clipsToBounds =NO;
        self.backgroundColor = [UIColor gray200Color];
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - Layout

-(void)layoutSubviews{
    
    [super layoutSubviews];
    [self.seeMoreButton setFrame:[self _seeMoreButtonFrame]];
    [self.contentView setFrame:[self _contentViewFrame]];
    [self.activityIndicator setFrame:[self _activityIndicatorFrame]];
}

-(CGRect)_seeMoreButtonFrame{
    return CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

-(CGRect)_contentViewFrame{
    return CGRectMake(5, 5, self.bounds.size.width - 2*5 , self.bounds.size.height - 2*5);
}

-(CGRect)_activityIndicatorFrame{
    return CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

#pragma mark - Private methods

-(void)loadState:(UIButton*)sender{
    self.alpha = 1.0;
    self.seeMoreButton.alpha = 0;
    [self.activityIndicator startAnimating];
}

#pragma mark - Public methods

-(void)initialState{
    self.alpha = 1.0f;
    self.seeMoreButton.alpha = 1;
    if (self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
    }
}

-(void)hiddenState{
    self.alpha = 0.0f;
//    self.seeMoreButton.alpha = 0;
    if (self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
    }
}

@end
