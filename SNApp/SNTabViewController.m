//
//  SNTabViewController.m
//  SNApp
//
//  Created by Force Close on 7/28/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNTabViewController.h"
#import "PostListViewController.h"
#import "SNLoginController.h"

@interface SNTabViewController ()<UITabBarControllerDelegate>

@property NSUInteger previousIndex;

@end

@implementation SNTabViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.previousIndex = 0;
    self.delegate = self;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSUInteger newIndex = self.selectedIndex;
    [self controlPreviousTabAtIndex:self.previousIndex nextTabAtIndex:newIndex];
    self.previousIndex = newIndex;
}

-(void)controlPreviousTabAtIndex:(NSUInteger)previousIndex nextTabAtIndex:(NSUInteger)nextIndex{
    switch (nextIndex) {
        case 0:
            if (self.selectedViewController == self.viewControllers[previousIndex]) {
                [(PostListViewController*)self.selectedViewController.childViewControllers[0] scrollToTop:nil];
            }
            break;
        case 1:
            if (self.selectedViewController == self.viewControllers[previousIndex]) {
                [(PostListViewController*)self.selectedViewController.childViewControllers[0] scrollToTop:nil];
            }
            break;
        case 2:{
            SNLoginController* loginController = [SNLoginController sharedController];
            if (![loginController verifyIsLogin]) {
                [loginController startLogin:SNLoginTypeExpandFunctions];
                self.selectedIndex = 0;
            }
            break;
        }
        case 3:
            
            break;
    }
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    NSUInteger previousIndex = self.selectedIndex>4?0:self.selectedIndex;
    [super setSelectedIndex:selectedIndex];
    NSUInteger newIndex = selectedIndex;
    [self controlPreviousTabAtIndex:previousIndex nextTabAtIndex:newIndex];
}

-(void)addBadgeNumber:(NSNumber*)number{
    UIViewController* controller = [self.viewControllers objectAtIndex:2];
    if (!(controller.isViewLoaded && controller.view.window)) {
        controller.tabBarItem.badgeValue = [NSString stringWithFormat:@"%@",number];
    }
}

@end
