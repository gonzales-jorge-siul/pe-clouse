//
//  AnotherReasonViewController.h
//  SNApp
//
//  Created by Force Close on 7/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AnotherReasonProtocol;

@interface AnotherReasonViewController : UIViewController

@property(nonatomic,strong)NSNumber* idPost;
@property(nonatomic,strong)NSNumber* reportAccountId;
@property(nonatomic,strong)id<AnotherReasonProtocol> delegate;

@end

@protocol AnotherReasonProtocol <NSObject>

-(void)anotherReportController:(AnotherReasonViewController*)controller done:(BOOL)done;

@end