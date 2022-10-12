//
//  AccountTableViewController.m
//  SNApp
//
//  Created by Force Close on 10/3/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "AccountTableViewController.h"
#import "Preferences.h"
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>
@interface AccountTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nearPostLabel;
@property (weak, nonatomic) IBOutlet UISwitch *NearPostSwitch;

@property (weak, nonatomic) IBOutlet UILabel *chatLabel;

@property (weak, nonatomic) IBOutlet UILabel *scopeLabel;
@property (weak, nonatomic) IBOutlet UISlider *scopeSlider;

- (IBAction)nearPostValueChanged:(id)sender;
- (IBAction)scopeValueChanged:(id)sender;

@end

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =NSLocalizedString(@"account.title", nil);
    
    
//    CTTelephonyNetworkInfo *phoneInfo = [[CTTelephonyNetworkInfo alloc] init];
//    CTCarrier *phoneCarrier = [phoneInfo subscriberCellularProvider];
//    self.nearPostLabel.text =NSLocalizedString( [phoneCarrier carrierName], nil);
//    
    self.nearPostLabel.text =NSLocalizedString( @"account.notification.Near Post", nil);
    self.NearPostSwitch.on = [[Preferences NotificationNearPost] boolValue];
    
    self.chatLabel.text =NSLocalizedString( @"account.notification.Chat", nil);
    
    self.scopeSlider.value = [[Preferences UserRadius] floatValue];
    int value =  roundf(self.scopeSlider.value);
    self.scopeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"account.scope.%d m", @"{scope distance in meters} m"),value];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


- (IBAction)nearPostValueChanged:(UISwitch*)sender {
    [Preferences setNotificationNearPost:sender.on?@YES:@NO];
}


- (IBAction)scopeValueChanged:(UISlider*)sender {
    int value = roundf(sender.value);
    self.scopeLabel.text = [NSString stringWithFormat:@"%d m",value];
}

- (IBAction)scopeTouchUp:(UISlider *)sender {
    int value = roundf(sender.value);
    [Preferences setUserRadius:@(value)];
}
- (IBAction)scopeTouchUpOutside:(UISlider *)sender {
    int value = roundf(sender.value);
    [Preferences setUserRadius:@(value)];
}

@end
