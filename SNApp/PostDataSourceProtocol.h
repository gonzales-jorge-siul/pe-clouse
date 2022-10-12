//
//  PostDataSourceDelegate.h
//  SNApp
//
//  Created by Force Close on 6/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Post.h"
@protocol PostDataSourceProtocol <NSObject>

@required

typedef NS_ENUM(NSInteger, SNPostSort){
    SNPostSortByDate =0,
    SNPostSortByRate =1
};

typedef NS_ENUM(NSInteger, SNPostDirection){
    SNPostLeft =0,
    SNPostRight ,
    SNPostTop ,
    SNPostBottom
};

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *navigationBarName;
@property (readonly) UIImage *tabBarImage;

@property (nonatomic,weak) UITableView* tableView;
@property (nonatomic,strong)NSNumber* thereIsNewPost;
@property (nonatomic,strong)NSNumber* shouldShowBackground;

@property (nonatomic,strong)NSNumber* sorted;
// provides a standardized means of asking for the element at the specific
// index path, regardless of the sorting or display technique for the specific
// datasource
//- (AtomicElement *)atomicElementForIndexPath:(NSIndexPath *)indexPath;

-(NSInteger)numberOfPost;
-(Post*)postForIndexPath:(NSIndexPath*)indexPath;
-(void)deletePostAtIndexPath:(NSIndexPath*)indexPath direction:(SNPostDirection)direction;


//-(BOOL)loadData:(NSError**)error;
-(BOOL)loadDataWithLocation:(CLLocation*)location error:(NSError**)error;
-(id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext location:(CLLocation*)location;

-(void)becomeFaultingPosts;

@end