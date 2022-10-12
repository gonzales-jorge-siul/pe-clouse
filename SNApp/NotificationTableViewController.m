//
//  NotificationTableViewController.m
//  SNApp
//
//  Created by Force Close on 10/10/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "NotificationTableViewController.h"

@interface NotificationTableViewController ()

@end

@implementation NotificationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"account.notification.Chat", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return NSLocalizedString(@"account.chats.disable-notifications.Section Title", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* contentString;
    UIImage* image;
    CGFloat height = 0 ;
    
    switch (indexPath.row) {
        case 0:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 1", nil)];
            image = [UIImage imageNamed:@"settingsAppIcon"];
            height += 8;
            break;
        case 1:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 2", nil)];
            image = [UIImage imageNamed:@"notificationIcon"];
            break;
        case 2:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 3", nil)];
            image = [UIImage imageNamed:@"apIcon"];
            break;
        case 3:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 4", nil)];
            image = [UIImage imageNamed:@"switchIcon"];
            break;
        case 4:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 5", nil)];
            image = [UIImage imageNamed:@"switchIcon"];
            break;
        case 5:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 6", nil)];
            image = [UIImage imageNamed:@"bannerIcon"];
            height += 8;
            break;
    }
    
    UIImage* scaledImage = [UIImage imageWithCGImage:[image CGImage] scale:image.scale * 2.2f orientation:image.imageOrientation];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = scaledImage;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(3, 1) withAttributedString:attrStringWithImage];
    
    height += [attributedString boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 2*20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
    
    return height + 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Steps Cell" forIndexPath:indexPath];
    
    NSString* contentString;
    UIImage* image;
    
    switch (indexPath.row) {
        case 0:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 1", nil)];
            image = [UIImage imageNamed:@"settingsAppIcon"];
            break;
        case 1:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 2", nil)];
            image = [UIImage imageNamed:@"notificationIcon"];
            break;
        case 2:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 3", nil)];
            image = [UIImage imageNamed:@"apIcon"];
            break;
        case 3:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 4", nil)];
            image = [UIImage imageNamed:@"switchIcon"];
            break;
        case 4:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 5", nil)];
            image = [UIImage imageNamed:@"switchIcon"];
            break;
        case 5:
            contentString = [NSString stringWithFormat:@"%ld.    %@",(long)(indexPath.row + 1), NSLocalizedString(@"account.chats.disable-notifications.Step 6", nil)];
            image = [UIImage imageNamed:@"bannerIcon"];
            break;
    }
    
    UIImage* scaledImage = [UIImage imageWithCGImage:[image CGImage] scale:image.scale * 2.f orientation:image.imageOrientation];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = scaledImage;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString replaceCharactersInRange:NSMakeRange(3, 1) withAttributedString:attrStringWithImage];
    
    cell.textLabel.attributedText = attributedString;
    cell.textLabel.numberOfLines = 0;
    cell.separatorInset = UIEdgeInsetsZero;
    
    return cell;
}


@end
