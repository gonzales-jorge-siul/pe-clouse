//
//  PostListView.m
//  SNApp
//
//  Created by Force Close on 7/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostListView.h"
#import "UIColor+SNColors.h"
//#import "UIImageView+AnimationCompletion.h"

@interface PostListView ()

@property(nonatomic,strong)UILabel* message;
@property(nonatomic,getter=isNewsButtonVisible)BOOL newsButtonVisible;
@property(nonatomic,strong)UIImageView* newLocationView;

//Table view background view
//@property(nonatomic,weak)UIImageView* imageBackgroundView;
@property(nonatomic,weak)UIImageView* imageTopBackgroundView;
@property(nonatomic,weak)UILabel* labelBackground;

@end

@implementation PostListView
#pragma mark - Life cycle
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //Table view
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setShowsHorizontalScrollIndicator:NO];
        [_tableView setShowsVerticalScrollIndicator:NO];
        
        UIView*  backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        backgroundView.backgroundColor = [UIColor whiteColor];
//        backgroundView.backgroundColor = [[UIColor appMainColor] colorWithAlphaComponent:0.9];
        
//        UIImageView* imageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableViewBackground"]];
//        imageBackgroundView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView* imageTopBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyPost"]];
        imageTopBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"addPostIcon"] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor appMainColor]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        button.layer.cornerRadius = 30.f;

        NSString* text = NSLocalizedString(@"post.background-message.There are not post near", nil);
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]} context:nil].size;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, textSize.height)];
        label.font = [UIFont boldSystemFontOfSize:20.f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1.f];
//        label.textColor =[UIColor whiteColor];
        label.numberOfLines = 0;
        label.text = text;
        
        [backgroundView addSubview:label];
//        [backgroundView addSubview:imageBackgroundView];
        [backgroundView addSubview:imageTopBackgroundView];
        [backgroundView addSubview:button];
        
        //Asign
        _tableView.backgroundView = backgroundView;
//        _imageBackgroundView = imageBackgroundView;
        _imageTopBackgroundView = imageTopBackgroundView;
        _labelBackground = label;
        _buttonBackground = button;
        
        //Footer view
        _footerView  = [[ViewMoreFooter alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        _tableView.tableFooterView = _footerView;
        
        [self addSubview:_tableView];
//        [self addSubview:button];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.tableView setFrame:[self _tableViewFrame]];
//    [self.imageBackgroundView setFrame:[self _imageBackgroundViewFrame]];
    [self.imageTopBackgroundView setFrame:[self _imageTopBackgroundViewFrame]];
    [self.labelBackground setFrame:[self _labelBackgroundFrame]];
    [self.buttonBackground setFrame:[self _buttonBackgroundFrame]];
}
#pragma mark - Layout helpers

-(CGRect)_tableViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

//-(CGRect)_imageBackgroundViewFrame{
//    CGSize imageSize = self.imageBackgroundView.image.size;
//    CGSize size = self.bounds.size;
//    CGFloat scale = size.width/imageSize.width;
//    CGFloat height = imageSize.height*scale;
//    CGFloat width = imageSize.width*scale;
//    return CGRectMake(0, size.height - height , width, height);
//}

-(CGRect)_imageTopBackgroundViewFrame{
    CGSize imageSize = self.imageTopBackgroundView.image.size;
    CGSize size = self.bounds.size;
    CGFloat scale = size.width/imageSize.width;
    //scale = scale*0.9;
    CGFloat height = imageSize.height*scale;
    CGFloat width = imageSize.width*scale;
    CGFloat heightView = self.tableView.bounds.size.height;
    
    return CGRectMake(50, (heightView-height)/2.f, width-100, height-100);
}

-(CGRect)_labelBackgroundFrame{
    CGRect imageTopFrame  = self.imageTopBackgroundView.frame;
    CGSize textSize = [self.labelBackground sizeThatFits:CGSizeMake(self.tableView.bounds.size.width, MAXFLOAT)];
    return CGRectMake(0, imageTopFrame.size.height + imageTopFrame.origin.y + 10, self.tableView.bounds.size.width, textSize.height);
}

-(CGRect)_buttonBackgroundFrame{
    return CGRectMake(self.bounds.size.width - 60 - 10, self.bounds.size.height -60 - 10, 60, 60);
}

#pragma mark - Custom accessors

CGFloat const HEIGHT_NEWS_BUTTON = 30.f;

-(UILabel *)message{
    if (!_message) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines =1;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        label.frame = CGRectMake(0, -14, self.bounds.size.width, 14.0);
        [self addSubview:label];
        _message =label;
    }
    return _message;
}
-(UIButton *)newsButton{
    if (!_newsButton) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"post.upper-message.new posts", nil) forState:UIControlStateNormal];
        button.tintColor = [UIColor whiteColor];
        button.backgroundColor = [UIColor appMainColor];
        button.layer.cornerRadius =7.0;
        button.clipsToBounds = YES;
        
        CGFloat width =[button.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:button.titleLabel.font} context:nil].size.width;
        width += 14;
        button.frame =CGRectMake((self.bounds.size.width-width)/2.f, -HEIGHT_NEWS_BUTTON, width, HEIGHT_NEWS_BUTTON);
        [self addSubview:button];
        _newsButton = button;
    }
    return _newsButton;
}

-(UIImageView *)newLocationView{
    if (!_newLocationView) {
        UIImageView* view  = [[UIImageView alloc] initWithFrame:self.bounds];
        view.animationImages = @[[UIImage imageNamed:@"bat1Icon"],[UIImage imageNamed:@"bat2Icon"],[UIImage imageNamed:@"bat3Icon"],[UIImage imageNamed:@"bat4Icon"]];
        view.animationDuration = 1;
        view.animationRepeatCount = 3;
        view.contentMode = UIViewContentModeCenter;
        view.backgroundColor = [UIColor gray800Color];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, [UIFont systemFontOfSize:20].lineHeight)];
        label.numberOfLines = 1;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"post.new-location.Updating your location", nil);
        [view addSubview:label];
        
        _newLocationView = view;
    }
    return _newLocationView;
}
#pragma mark - Public
-(void)showMessageAtTop:(NSString *)message{
    self.message.text =message;
    if (self.isMessageAtTopVisible) {
        [self.message setNeedsDisplay];
    }else{
        PostListView* __weak weakSelf = self;
        CGRect rect = self.message.frame;
        [UIView animateWithDuration:0.15 animations:^{
            weakSelf.message.frame =CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
        }];
        self.messageAtTopVisible = YES;
    }
}
-(void)dismissMessageAtTop{
    if (!self.isMessageAtTopVisible) {
        return;
    }
    CGRect rect = self.message.frame;
    PostListView* __weak weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.message.frame = CGRectMake(rect.origin.x, -14, rect.size.width, rect.size.height) ;
    }];
    self.messageAtTopVisible = NO;
}
-(void)showNewsButton{
    if (self.isNewsButtonVisible) {
        return;
    }
   
    CGRect rect = self.newsButton.frame;
    PostListView* __weak weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.newsButton.frame =CGRectMake(rect.origin.x, 10, rect.size.width, rect.size.height);
    }];
    self.newsButtonVisible = YES;
}
-(void)dismissNewsButton{
    if(!self.isNewsButtonVisible){
        return;
    }
    CGRect rect = self.newsButton.frame;
    PostListView* __weak weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.newsButton.frame = CGRectMake(rect.origin.x, -HEIGHT_NEWS_BUTTON, rect.size.width, rect.size.height);
    }];
    self.newsButtonVisible = NO;
}

-(void)showNewLocationImage{
    [self addSubview:self.newLocationView];
    PostListView* __weak weakSelf = self;
    //[self.newLocationView startAnimatingWithCompletionBlock:^(BOOL success) {
    //    [weakSelf dismissNewLocationImage];
    //}];
}
-(void)dismissNewLocationImage{
    [self.newLocationView stopAnimating];
    [self.newLocationView removeFromSuperview];
}


@end
