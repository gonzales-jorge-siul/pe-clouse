//
//  ChatTitleView.h
//  SNApp
//
//  Created by Force Close on 8/25/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLastConnection.h"

@interface ChatTitleView : UIView

@property(nonatomic,strong)NSString* title;
@property(nonatomic,strong)UserLastConnection* userLastConnection;

@end
