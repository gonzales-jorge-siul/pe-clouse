//
//  SNObjectManager.m
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Jorge . All rights reserved.
//

#import "SNObjectManager.h"
#import <RKCoreData.h>
#import <RestKit/RestKit.h>
#import "RKHTTPRequestOperation_Timeoutable.h"

@implementation SNObjectManager

+(instancetype)sharedManager{
    static SNObjectManager *sharedManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        NSURL *baseUrl = [NSURL URLWithString:@"http://188.226.186.113:8080"];
        sharedManager = [self managerWithBaseURL:baseUrl];
        [sharedManager setupPersistenStore];
        [AFNetworkActivityIndicatorManager sharedManager].enabled =YES;
        [sharedManager registerRequestOperationClass:[RKHTTPRequestOperation_Timeoutable class]];
    });
    
    return sharedManager;
}

#pragma mark - Helpers

-(void)setupPersistenStore{
    
    NSError *error = nil;
    NSURL *urlMom = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SNApp" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:urlMom];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    //
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (!success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@' : %@",RKApplicationDataDirectory(),error);
    }
    NSString *path = [RKApplicationDataDirectory() stringByAppendingString:@"/SNApp.sqlite"];
    
    //Uncomment line bellow to keep data in memory
    //NSPersistentStore* persistentStore=[managedObjectStore addInMemoryPersistentStore:&error];

    NSPersistentStore *persistentStore =[managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    //
    if (!persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@' : %@",RKApplicationDataDirectory(),error);
    }
    [managedObjectStore createManagedObjectContexts];
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    self.managedObjectStore = managedObjectStore;
}
@end




//_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TestCoreData.sqlite"];
//NSError *error = nil;
//NSString *failureReason = @"There was an error creating or loading the application's saved data.";
//if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//    // Report any error we got.
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
//    dict[NSLocalizedFailureReasonErrorKey] = failureReason;
//    dict[NSUnderlyingErrorKey] = error;
//    error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//    // Replace this with code to handle the error appropriately.
//    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//    abort();
//}
//
//return _persistentStoreCoordinator;