//
//  ReportTableViewController.m
//  SNApp
//
//  Created by Force Close on 7/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ReportTableViewController.h"
#import "SNPostResourceManager.h"
#import "Account.h"
#import "AnotherReasonViewController.h"

@interface ReportTableViewController ()<AnotherReasonProtocol>

@property(nonatomic,strong)NSArray* rowsSection1;
@property(nonatomic,strong)NSArray* rowsSection2;
@property(nonatomic)NSInteger selectedRow;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation ReportTableViewController

CGFloat const NUMBER_OF_SECTIONS_REPORT = 2.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"report.title", nil);
    
    self.rowsSection1 = @[NSLocalizedString(@"report.reasons.reason1", nil),
                          NSLocalizedString(@"report.reasons.reason2", nil),
                          NSLocalizedString(@"report.reasons.reason3", nil),
                          NSLocalizedString(@"report.reasons.reason4", nil),
                          NSLocalizedString(@"report.reasons.reason5", nil)];
    self.rowsSection2 = @[NSLocalizedString(@"report.reasons.reason6", nil)];
    self.selectedRow = 0;
    
    //Back button
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS_REPORT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.rowsSection1.count;
        case 1:
            return self.rowsSection2.count;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Reason Cell" forIndexPath:indexPath];
            cell.textLabel.text = [self rowsSection1][indexPath.row];
            if (self.selectedRow==indexPath.row) {
                cell.accessoryType =  UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"Another Reason Cell" forIndexPath:indexPath];
            cell.textLabel.text = [self rowsSection2][indexPath.row];
            break;
    }
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            self.selectedRow = indexPath.row;
            [tableView reloadData];
            break;
        case 1:
            
            break;
        default:
            break;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AnotherReasonViewController* controller = (AnotherReasonViewController*)[segue destinationViewController];
    controller.idPost = self.idPost;
    controller.reportAccountId = self.reportedAccountId;
    controller.delegate = self;
}

#pragma mark - Actions
- (IBAction)cancel:(id)sender {
    if (self.delegate) {
        [self.delegate reportController:self done:NO];
    }
}

- (IBAction)done:(id)sender {
    ReportTableViewController* __weak weakSelf = self;
    [[SNPostResourceManager sharedManager] reportPostWithIdAccount:[Account accountId] idPost:self.idPost?self.idPost:@(-1) idAccountReport:self.reportedAccountId?self.reportedAccountId:@(-1) detail:[self rowsSection1][self.selectedRow] success:^(ResponseServer *response) {
        if (weakSelf.delegate) {
            [weakSelf.delegate reportController:self done:YES];
        }
    } failure:^(NSError *error) {
        if (weakSelf.delegate) {
            [weakSelf.delegate reportController:self done:NO];
        }
    }];
}

#pragma mark - Another reason delegate
-(void)anotherReportController:(AnotherReasonViewController *)controller done:(BOOL)done{
    if (done) {
        if (self.delegate) {
            [self.delegate reportController:self done:YES];
        }
    }else{
        if (self.delegate) {
            [self.delegate reportController:self done:NO];
        }
    }
}

@end
