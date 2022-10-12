//
//  SNGrettingsViewController.m
//  SNApp
//
//  Created by Force Close on 8/10/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNGrettingsViewController.h"
#import "Account.h"
#import "SNLoginController.h"

@interface SNGrettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *instruccionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;

@end

@implementation SNGrettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [NSTimer scheduledTimerWithTimeInterval:8.f target:self selector:@selector(endWithTimer:) userInfo:nil repeats:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bubbleImageView.image = [[UIImage imageNamed:@"chatBubbleLeftIcon"]resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 8, 8) resizingMode:UIImageResizingModeStretch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Actions

-(IBAction)done:(id)sender{
    [[SNLoginController sharedController] dismissLogin];
}

-(void)endWithTimer:(NSTimer *)timer{
    [[SNLoginController sharedController] dismissLogin];
}

#pragma mark - Helpers

-(void)setupView{
    //Navigation bar
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //Right bar button
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"app.general.done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //Texts
    self.welcomeLabel.text = NSLocalizedString(@"login.grettins.welcome", nil);
    self.usernameLabel.text = [Account username];
    self.instruccionLabel.text = NSLocalizedString(@"login.grettings.thanks", nil);
}

@end
