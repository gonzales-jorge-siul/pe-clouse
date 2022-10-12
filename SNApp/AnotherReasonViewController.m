//
//  AnotherReasonViewController.m
//  SNApp
//
//  Created by Force Close on 7/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "AnotherReasonViewController.h"
#import "SNPostResourceManager.h"
#import "Account.h"

@interface AnotherReasonViewController ()

- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *reasonText;
@property (weak, nonatomic) IBOutlet UILabel *instruccion;


@end

@implementation AnotherReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reasonText.layer.borderColor = [[UIColor grayColor] CGColor];
    self.reasonText.layer.borderWidth = 2.f;
    self.reasonText.layer.cornerRadius = 4.f;
    self.reasonText.backgroundColor =[UIColor whiteColor];
    self.navigationItem.title =NSLocalizedString(@"report.another-reason.title", nil);
    self.instruccion.text = NSLocalizedString(@"report.another-reason.instruccion.specifies another reason", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    if (self.reasonText.text.length !=0) {
        [self.reasonText resignFirstResponder];
        AnotherReasonViewController* __weak weakSelf = self;
        [[SNPostResourceManager  sharedManager] reportPostWithIdAccount:[Account accountId] idPost:self.idPost?self.idPost:@(-1) idAccountReport:self.reportAccountId?self.reportAccountId:@(-1) detail:self.reasonText.text success:^(ResponseServer *response) {
            if (weakSelf.delegate) {
                [weakSelf.delegate anotherReportController:self done:YES];
            }
        } failure:^(NSError *error) {
            if (weakSelf.delegate) {
                [weakSelf.delegate anotherReportController:self done:NO];
            }
        }];
    }
}

@end
