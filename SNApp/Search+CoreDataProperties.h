//
//  Search+CoreDataProperties.h
//  SNApp
//
//  Created by Force Close on 10/7/15.
//  Copyright © 2015 Force Close. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Search.h"

NS_ASSUME_NONNULL_BEGIN

@interface Search (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *searchText;
@property (nullable, nonatomic, retain) NSDate *date;

@end

NS_ASSUME_NONNULL_END
