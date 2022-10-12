//
//  SNTestViewController.m
//  SNApp
//
//  Created by Force Close on 6/12/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNTestViewController.h"
#import "Preferences.h"

@interface SNTestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *testDEfault;

@end

@implementation SNTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testDEfault.text = [[Preferences UserIsLogin] description];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
