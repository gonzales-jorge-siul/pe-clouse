//
//  SNLoginController.m
//  SNApp
//
//  Created by Force Close on 7/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNLoginController.h"
#import "SNGCMService.h"
#import "Preferences.h"

#import "SNAccountResourceManager.h"
#import "SNObjectManager.h"
#import "SNConstans.h"

@interface SNLoginController ()

@property(nonatomic,strong)NSNumber* canStartLogin;
@property(nonatomic,strong,getter=isStartedLogin)NSNumber* startedLogin;

@end

@implementation SNLoginController

+(instancetype)sharedController{
    
    static SNLoginController* sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedController = [[self alloc] init];
        [sharedController subscribeToNotifications];
        sharedController.canStartLogin = @NO;
        sharedController.startedLogin = @NO;
    });
    return sharedController;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

-(void)GCMRequirementsNotifications:(NSNotification*)notification{
    if (notification.userInfo[@"error"]) {
        return;
    }
    self.canStartLogin = @YES;
    
    NSString* newCloudId = notification.userInfo[@"registrationToken"];
    NSNumber* loginTimes = [Preferences UserTimesTryLogin];

    [Preferences setUserTimesTryLogin:@([loginTimes intValue]+1)];
    
    if ([loginTimes intValue]==0) {
        [Account setCloudId:newCloudId];
        [self startLogin:SNLoginTypeNormal];
        NSLog(@"%@",@"First time cloud ID");
    }else{
        NSString* oldCloudId = [Account cloudId];
        if ([oldCloudId isEqualToString:newCloudId]) {
            if (![self verifyIsLogin] && ![self verifyIsGuest]) {
                [self registerAsGuest:nil];
            }else{
                [self verifyAccountId];
            }
        }else if ([self verifyIsLogin] || [self verifyIsGuest]){
            [self updateCloudId:newCloudId];
            [self verifyAccountId];
        }else{
            [Account setCloudId:newCloudId];
            [self registerAsGuest:nil];
        }
    }
}

#pragma mark - Public
//
-(void)startLogin:(SNLoginType)loginType{
    if (![self.isStartedLogin boolValue]/* && [self.canStartLogin boolValue]*/) {
        UIWindow* window = [[UIApplication sharedApplication] windows][0];
        UITabBarController* mainController =(UITabBarController*)[window rootViewController];
        if (mainController.isViewLoaded && mainController.view.window) {
            if (loginType == SNLoginTypeDirect) {
                [self showLoginUIOnController:mainController];
            }else{
                [self showLoginUIOnController:mainController loginType:loginType];
            }
            self.startedLogin = @YES;
        }
    }else if(![self.canStartLogin boolValue]){
        [self showMessage:NSLocalizedString(@"login-controller.message.problems", nil) title:NSLocalizedString(@"login-controller.title.problems", nil)];
    }
}

-(void)dismissLogin{
    if ([self.isStartedLogin boolValue]) {
        UIWindow* window = [[UIApplication sharedApplication] windows][0];
        UITabBarController* mainController =(UITabBarController*)[window rootViewController];
        [mainController dismissViewControllerAnimated:YES completion:nil];
        self.startedLogin = @NO;
    }
}

-(void)verifyAccountId{
    if ([self verifyIsLogin] || [self verifyIsGuest]) {
        SNLoginController* __weak weakSelf= self;
        [[SNAccountResourceManager sharedManager] verifyStateAccount:[Account accountId] success:^(ResponseServer *response) {
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *newState = [formatter numberFromString:response.response];
            [weakSelf accountSetState:newState];
            [weakSelf verifyState];
        } failure:^(NSError *error) {
            if ([error.domain isEqualToString:SNSERVICES_ERROR_DOMAIN]) {
                switch (error.code) {
                    case SNNoServer:
                        NSLog(@"%@",@"Failure verify account");
                        break;
                }
            }
        }];
    }
}

-(SNAccountState)verifyAccount{
    if ([self verifyIsLogin]) {
        return [self verifyState];
    }else{
        if ([self verifyIsGuest]) {
            return [self verifyState];
        }else{
            //If reach this point it means there isn't a user register,
            //so default state when an account is created is Normal
            [self registerAsGuest:nil];
            return SNAccountStateRequest;
        }
    }
}

-(BOOL)verifyIsGuest{
    //Implement a way to verify real state of guests
    return [[Preferences UserIsGuest] boolValue];
}

-(BOOL)verifyIsLogin{
    //Implement a way to verify real state of current user
    return [[Preferences UserIsLogin] boolValue];
}
//
-(void)registerAsGuest:(void (^)(BOOL success, NSError* error))success {
    if (![self verifyIsGuest] && ![self verifyIsLogin] && [[self canStartLogin] boolValue]) {
        [[SNAccountResourceManager sharedManager] cancelLoginAsGuest];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy_MM_dd'T'HH_mm_ss.SSS"];
        
        NSString* username = [NSString stringWithFormat:@"IOSGuest%@",[formatter stringFromDate:[NSDate date]]];
        NSString* cloudId = [Account cloudId];
        SNLoginController* __weak weakSelf= self;
        [[SNAccountResourceManager sharedManager] loginAsGuest:username cloudId:cloudId success:^(Account *account) {
            [weakSelf setAccountData:account];
            [weakSelf verifyState];
            if (success) {
                success(YES,nil);
            }
            NSLog(@"%@",@"Registered as guest");
        } failure:^(NSError *error) {
            if ([error.domain isEqualToString:SNSERVICES_ERROR_DOMAIN]) {
                switch (error.code) {
                    case SNNoServer:{
                        [weakSelf showMessage:NSLocalizedString(@"login-controller.message.problems", nil) title:NSLocalizedString(@"login-controller.title.problems", nil)];
                        if (success) {
                            success(NO,error);
                        }
                        break;
                    }
                }
            }

        }];
    }else if(![[self canStartLogin] boolValue]){
        [self showMessage:NSLocalizedString(@"login-controller.message.problems", nil) title:NSLocalizedString(@"login-controller.title.problems", nil)];
        if (success) {
            success(NO,nil);
        }
    }
}

#pragma mark - Private

-(SNAccountState)verifyState{
    switch ([[Account state] intValue]) {
        case SNAccountStateBlock:
            NSLog(@"%@",@"SNAccountStateBlock");
            [self verifyAccountStateActionBlock];
            return SNAccountStateBlock;
        case SNAccountStateNormal:
            //Nothing to do
            NSLog(@"%@",@"SNAccountStateNormal");
            return SNAccountStateNormal;
        case SNAccountStateUnverified:
            NSLog(@"%@",@"SNAccountStateUnverified");
            [self verifyAccountStateActionUnverified];
            return SNAccountStateUnverified;
        case SNAccountStateGuest:
            NSLog(@"%@",@"SNAccountStateGuest");
            [self verifyAccountStateActionGuest];
            return SNAccountStateGuest;
        default:
            //Do something to reset state when state is undeterminate
            return SNAccountStateNormal;
    }
}

#pragma mark - Helpers

-(void)subscribeToNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCMRequirementsNotifications:) name:GCMRegistrationComplete object:nil];
}

-(void)showLoginUIOnController:(UIViewController*)controller loginType:(SNLoginType)loginType{
    
    NSString* title;
    NSString* message;
    
    switch (loginType) {
        case SNLoginTypeNormal:
            title = NSLocalizedString(@"login-controller.types.login-title", nil);
            message = NSLocalizedString(@"login-controller.types.login-message", nil);
            break;
        case SNLoginTypeUnverified:
            title = NSLocalizedString(@"login-controller.types.verify-title", nil);
            message = NSLocalizedString(@"login-controller.types.verify-message", nil);
            break;
        case SNLoginTypeExpandFunctions:
            title = NSLocalizedString(@"login-controller.types.expand-functions-title", nil);
            message = NSLocalizedString(@"login-controller.types.expand-functions-message", nil);
            break;
        case SNLoginTypeDirect:
            return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [controller presentViewController:navController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        self.startedLogin = @NO;
        if (![self verifyIsLogin]&&![self verifyIsGuest]) {
            [self registerAsGuest:nil];
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [controller presentViewController:alert animated:YES completion:nil];
}
-(void)showLoginUIOnController:(UIViewController*)controller{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
    [controller presentViewController:navController animated:YES completion:nil];
}

-(void)showMessage:(NSString*)message title:(NSString*)title {
    UIWindow* window = [[UIApplication sharedApplication] windows][0];
    UITabBarController* mainController =(UITabBarController*)[window rootViewController];
    if (mainController.isViewLoaded && mainController.view.window) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [mainController presentViewController:alert animated:YES completion:nil];
    }
}

-(void)updateCloudId:(NSString*)cloudId{
    self.canStartLogin = @NO;
    [[SNAccountResourceManager sharedManager] updateCloudId:cloudId username:[Account username] success:^(ResponseServer *response) {
        //Save new cloudId
        [Account setCloudId:cloudId];
        self.canStartLogin = @YES;
        NSLog(@"%@",@"Updated CloudId");
    } failure:^(NSError *error) {
        if ([error.domain isEqualToString:SNSERVICES_ERROR_DOMAIN]) {
            switch (error.code) {
                case SNNoServer:
                    //If update no is possible, it is because server isn't reachable
                    NSLog(@"%@",@"Failure update cloudId");
                    break;
            }
        }
    }];
}

-(void)verifyAccountStateActionBlock{
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIWindow* window = [[UIApplication sharedApplication] windows][0];
    UIViewController* rootController = [storyBoard instantiateViewControllerWithIdentifier:@"Block View"];
    window.rootViewController = rootController;
}

-(void)verifyAccountStateActionUnverified{
    //Reset the app
    [Preferences setUserIsGuest:@NO];
    [Preferences setUserIsLogin:@NO];
    [Preferences setUsername:@""];
    [self deleteChats];
    [self startLogin:SNLoginTypeUnverified];
}

-(void)verifyAccountStateActionGuest{
    [Preferences setUserIsLogin:@NO];
    [Preferences setUserIsGuest:@YES];
}
-(void)deleteChats{
    NSManagedObjectContext* context = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    NSFetchRequest *allChats = [[NSFetchRequest alloc] init];
    [allChats setEntity:[NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context]];
    [allChats setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *cars = [context executeFetchRequest:allChats error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    for (NSManagedObject *car in cars) {
        [context deleteObject:car];
    }
    NSError *saveError = nil;
    if ([context hasChanges] && ![context save:&saveError]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)deleteCurrentAccount{
    
}


#pragma mark - Helpers blocks

-(void)accountSetState:(NSNumber*)newState{
    [Account setState:newState];
}

-(void)setAccountData:(Account*)account{
    [Preferences setUserIsGuest:@YES];
    [Preferences setUserIsLogin:@NO];
    [Account setAccountId:account.idAccount];
    [Account setUsername:account.username];
    [Account setState:@(SNAccountStateGuest)];
}

@end
