//
//  ProfileView.h
//  SNApp
//
//  Created by Force Close on 7/4/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@interface ProfileView : UIView
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UIButton* sendMessageButton;
@property(nonatomic,strong)Account* account;
@end
