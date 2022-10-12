//
//  ProfileView.m
//  SNApp
//
//  Created by Force Close on 7/4/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ProfileView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+SNColors.h"

@interface ProfileView ()

@property(nonatomic,strong)UIImageView* photo;
@property(nonatomic,strong)UIView* photoContainer;

@property(nonatomic,strong)UIView* nameContainer;
@property(nonatomic,strong)UILabel* name;

@property(nonatomic,strong)UIView* usernameContainer;
@property(nonatomic,strong)UILabel* username;
@property(nonatomic,strong)UILabel* profileText;
@end

@implementation ProfileView
#pragma mark - Life cycle
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //Table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        _tableView.allowsSelection=NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor gray200Color];
        _tableView.alwaysBounceVertical = NO;
        [self addSubview:_tableView];
        
        _usernameContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _usernameContainer.backgroundColor = [UIColor appMainColor];
        
        _username = [[UILabel alloc] initWithFrame:CGRectZero];
        _username.font = [UIFont systemFontOfSize:16.f];
        _username.textColor = [UIColor whiteColor];
        _username.textAlignment = NSTextAlignmentRight;
        
        _profileText = [[UILabel alloc] initWithFrame:CGRectZero];
        _profileText.textAlignment = NSTextAlignmentLeft;
        _profileText.textColor = [UIColor whiteColor];
        _profileText.font = [UIFont systemFontOfSize:16.0];
        _profileText.text = NSLocalizedString(@"profile.header.Profile", nil);
        
        [_usernameContainer addSubview:_username];
        [_usernameContainer addSubview:_profileText];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.tableView setFrame:[self _tableViewFrame]];
}
-(CGRect)_tableViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}
-(CGSize)_nameSize:(NSString*)text{
    return [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width*0.8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]} context:nil].size;
}
-(CGSize)_nicknameSize:(NSString*)text{
    return [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width*0.8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]} context:nil].size;
}
-(CGSize)_statusSize:(NSString*)text{
    return [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width-16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20.0]} context:nil].size;
}
#pragma mark - Custom accesors
-(void)setAccount:(Account *)account{
    _account = account;
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width +24)];
    
    //self.photo.frame =CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.width);
    //self.photoContainer.frame = self.photo.bounds;
    //self.photoContainer.backgroundColor = [UIColor clearColor];
    //[self addGradientToView:_photoContainer];
    
    self.nameContainer.frame = CGRectMake(0, self.photo.bounds.size.height - 52, self.photo.bounds.size.width, 52);
    self.sendMessageButton.frame = CGRectMake(self.nameContainer.bounds.size.width - 6 - 40, 6 , 40, 40);
    self.name.frame = CGRectMake(6, 0, self.nameContainer.bounds.size.width - 6 - 40 - 6, 52);
    
    self.usernameContainer.frame = CGRectMake(0, self.photo.bounds.size.height, view.bounds.size.width, 30);
    self.username.frame = CGRectMake(6, 0, self.usernameContainer.bounds.size.width -6 -6, 30);
    self.profileText.frame = self.username.frame;

    if (![self.account.photo isEqualToString:@""]) {
        [self.photo setImageWithURL:[NSURL URLWithString:self.account.photo] placeholderImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    }else{
        [self.photo setImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    }
    
    self.name.text = [self.account.name uppercaseString];
    
    self.username.text = [[NSString stringWithFormat:@"@%@",self.account.username] lowercaseString];
    
    [view addSubview:self.photo];
    [view addSubview:self.usernameContainer];
    self.tableView.tableHeaderView = view;
}

-(UIImageView *)photo{
    if (!_photo) {
        UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
        [view addSubview:self.photoContainer];
        view.userInteractionEnabled = YES;
        _photo = view;
    }
    return _photo;
}

-(UIView *)photoContainer{
    if (!_photoContainer) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
        [self addGradientToView:view];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:self.nameContainer];
        _photoContainer =view;
    }
    return _photoContainer;
}
-(UIView *)nameContainer{
    if (!_nameContainer) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];
        [view addSubview:self.name];
        [view addSubview:self.sendMessageButton];
        _nameContainer =view;
    }
    return _nameContainer;
}
-(UILabel *)name{
    if (!_name) {
        UILabel* view = [[UILabel alloc] initWithFrame:CGRectZero];
        view.textAlignment = NSTextAlignmentLeft;
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont systemFontOfSize:18.f];
        view.numberOfLines = 2;
        _name = view;
    }
    return _name;
}

-(UIButton *)sendMessageButton{
    if (!_sendMessageButton) {
        UIButton* view = [[UIButton alloc] initWithFrame:CGRectZero];
        [view setImage:[UIImage imageNamed:@"chatProfileIcon"] forState:UIControlStateNormal];
        [view setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        view.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _sendMessageButton = view;
    }
    return _sendMessageButton;
}

- (void)addGradientToView:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height * 0.2);
    
    gradient.colors = @[(id)[[[UIColor blackColor] colorWithAlphaComponent:0.25] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    [view.layer insertSublayer:gradient atIndex:0];
}

@end
