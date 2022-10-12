//
//  PostListView.h
//  SNApp
//
//  Created by Force Close on 7/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewMoreFooter.h"

@interface PostListView : UIView

@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UIButton* newsButton;
@property(nonatomic,weak)UIButton* buttonBackground;
@property(nonatomic,getter=isMessageAtTopVisible)BOOL messageAtTopVisible;

@property(nonatomic,strong)ViewMoreFooter* footerView;

-(void)showMessageAtTop:(NSString*)message;
-(void)dismissMessageAtTop;

-(void)showNewsButton;
-(void)dismissNewsButton;

-(void)showNewLocationImage;
-(void)dismissNewLocationImage;

@end
