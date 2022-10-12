//
//  SearchResultsTableViewController.h
//  SNApp
//
//  Created by Force Close on 10/5/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "SearchTableViewController.h"

@interface SearchResultsTableViewController : UITableViewController

@property(nonatomic,strong)NSManagedObjectContext* managedObjectContext;

-(void)getPersistentData:(NSString*)searchText;
-(void)getData:(NSString*)searchText;
-(Account*)accountAtIndexPath:(NSIndexPath*)indexPath;

@end
