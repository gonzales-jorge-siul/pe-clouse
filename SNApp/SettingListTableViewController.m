//
//  SettingListTableViewController.m
//  SNApp
//
//  Created by Force Close on 7/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SettingListTableViewController.h"
#import "UIColor+SNColors.h"
#import "MyProfileTableViewController.h"
#import "SNLoginController.h"
#import "SNObjectManager.h"

@interface SettingListTableViewController ()

@property(nonatomic,strong)NSArray* rowsInSectionOne;
@property(nonatomic,strong)NSArray* rowsInSectionTwo;
@property(nonatomic,strong)NSArray* rowsInSectionTwoUnregistered;
@property(nonatomic,strong)NSArray* rowsInSectionThree;

@property(nonatomic,strong)NSArray* imageRowsInSectionOne;
@property(nonatomic,strong)NSArray* imageRowsInSectionTwo;
@property(nonatomic,strong)NSArray* imageRowsInSectionThree;

@end

@implementation SettingListTableViewController

NSInteger const NUMBER_OF_SECTIONS_SETTINGS= 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"settings.title", nil);
    self.navigationItem.title =  NSLocalizedString(@"settings.title", nil);
    
    self.navigationController.navigationBar.barTintColor = [UIColor appMainColor];
    self.navigationController.navigationBar.opaque =YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.rowsInSectionOne = @[NSLocalizedString(@"settings.categoty.about", nil),NSLocalizedString(@"settings.categoty.tell-a-friend", nil)];
    self.rowsInSectionTwo = @[NSLocalizedString(@"settings.categoty.my-profile", nil),NSLocalizedString(@"settings.categoty.account", nil)];
    self.rowsInSectionTwoUnregistered =@[NSLocalizedString(@"settings.categoty.my-profile-unregistered", nil),NSLocalizedString(@"settings.categoty.account", nil)];
    self.rowsInSectionThree =@[NSLocalizedString(@"settings.categoty.delete-chats", nil)];
    
    self.imageRowsInSectionOne=@[[UIImage imageNamed:@"infoSettingsIcon"],[UIImage imageNamed:@"shareSettingsIcon"]];
    self.imageRowsInSectionTwo=@[[UIImage imageNamed:@"personSettingsIcon"],[UIImage imageNamed:@"accountSettingsIcon"]];
    self.imageRowsInSectionThree=@[[UIImage imageNamed:@"deleteChatsSettingsIcon"]];
    
    //Back button
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS_SETTINGS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.rowsInSectionOne.count;
        case 1:
            return self.rowsInSectionTwo.count;
        case 2:
            return self.rowsInSectionThree.count;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Setting Cell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.rowsInSectionOne[indexPath.row];
            cell.imageView.image = self.imageRowsInSectionOne[indexPath.row];
            break;
        case 1:
            if ([[SNLoginController sharedController] verifyIsLogin]) {
                cell.textLabel.text = self.rowsInSectionTwo[indexPath.row];
            }else{
                cell.textLabel.text = self.rowsInSectionTwoUnregistered[indexPath.row];
            }
            cell.imageView.image = self.imageRowsInSectionTwo[indexPath.row];
            break;
        case 2:
            cell.textLabel.text = self.rowsInSectionThree[indexPath.row];
            cell.imageView.image = self.imageRowsInSectionThree[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self performSegueWithIdentifier:@"ToInfoSettings" sender:self];
                    break;
                case 1:
                    [self shareApp];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:{
                    if ([[SNLoginController sharedController] verifyIsLogin]) {
                        [self performSegueWithIdentifier:@"ToMyProfile" sender:self];
                        break;
                    }
                    [[SNLoginController sharedController] startLogin:SNLoginTypeDirect];
                    break;
                }
                case 1:
                    if ([[SNLoginController sharedController] verifyIsGuest]) {
                        [[SNLoginController sharedController] startLogin:SNLoginTypeExpandFunctions];
                        break;
                    }
                    [self performSegueWithIdentifier:@"ToAccount" sender:self];
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self deleteChats];
                    break;
             }
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma  mark - Helpers

-(void)shareApp{
    NSMutableArray *sharingItems = [NSMutableArray new];
  
    [sharingItems addObject:NSLocalizedString(@"settings-vc.share.share-message", nil)];
 
    [sharingItems addObject:[NSURL URLWithString:@"http://www.forceclose.pe"]];
    
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];

}

-(void)deleteChats{
    if ([[SNLoginController sharedController] verifyIsGuest]) {
        [[SNLoginController sharedController] startLogin:SNLoginTypeExpandFunctions];
        return;
    }
    
    NSString* title = NSLocalizedString(@"app.general.delete", nil);
    NSString* message = NSLocalizedString(@"settings-vc.delete.confirmation-message", nil);
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    SettingListTableViewController* __weak weakSelf = self;
    UIAlertAction* openAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [weakSelf deletePersistentChats];
    }];
    [alertController addAction:openAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)deletePersistentChats{
    NSManagedObjectContext* context = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    NSFetchRequest *allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *cars = [context executeFetchRequest:allCars error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    for (NSManagedObject *car in cars) {
        [context deleteObject:car];
    }
    NSError *saveError = nil;
    if ([context hasChanges] && ![context saveToPersistentStore:&saveError]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToMyProfile"]) {
        MyProfileTableViewController* controller  = [segue destinationViewController];
        controller.hidesBottomBarWhenPushed = YES;
    }else if ([segue.identifier isEqualToString:@"ToAccount"]) {
        UITableViewController* controller = [segue destinationViewController];
        controller.hidesBottomBarWhenPushed = YES;
    }else if ([segue.identifier isEqualToString:@"ToInfoSettings"]){
        [[segue destinationViewController] setHidesBottomBarWhenPushed:YES];
    }
}

@end
