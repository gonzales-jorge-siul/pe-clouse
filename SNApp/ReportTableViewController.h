//
//  ReportTableViewController.h
//  SNApp
//
//  Created by Force Close on 7/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReportProtocol;

@interface ReportTableViewController : UITableViewController

@property(nonatomic,strong)NSNumber* idPost;
@property(nonatomic,strong)NSNumber* reportedAccountId;
@property(nonatomic,weak)id<ReportProtocol> delegate;

@end

@protocol ReportProtocol <NSObject>

-(void)reportController:(ReportTableViewController*)controller done:(BOOL)done;

@end
