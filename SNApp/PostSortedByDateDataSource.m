//
//  PostSortedByDateDataSource.m
//  SNApp
//
//  Created by Force Close on 6/17/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "PostSortedByDateDataSource.h"
#import <CoreData/CoreData.h>
#import "SNObjectManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Post.h"
#import "SNLocationManager.h"
#import "PostBaseTableViewCell.h"
#import "PostStyleTextTableViewCell.h"
#import "PostStylePhotoTableViewCell.h"
#import "PostStylePhotoAndTextTableViewCell.h"
#import "SNPostResourceManager.h"
#import "ResponseServer.h"
#import "SNLoginController.h"
#import "Preferences.h"
#import "PostListViewController.h"

@interface PostSortedByDateDataSource ()<NSFetchedResultsControllerDelegate>

@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,strong) NSMutableArray* visibleRows;
@property(nonatomic,strong) NSMutableArray* moveRows;
@property(nonatomic,strong) NSNumber* insertRows;
@property(nonatomic,strong) NSNumber* offset;

@property(nonatomic) BOOL deletePost;
@property(nonatomic) SNPostDirection directionToDelete;

@end

@implementation PostSortedByDateDataSource

@synthesize tableView = _tableView;
@synthesize thereIsNewPost = _thereIsNewPost;
@synthesize sorted = _sorted;
@synthesize shouldShowBackground = _shouldShowBackground;

#pragma mark - Life cycle

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext location:(CLLocation*)location{
    self = [super init];
    if (self) {
        
        // Fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Set entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        double D = [[Preferences UserStepRadius] doubleValue] ;
        double R = 6371009.;
        double meanLatitidue = location.coordinate.latitude * M_PI / 180.;
        double deltaLatitude = D / R * 180. / M_PI;
        double deltaLongitude = D / (R * cos(meanLatitidue)) * 180. / M_PI;
        double minLatitude = location.coordinate.latitude - deltaLatitude;
        double maxLatitude = location.coordinate.latitude + deltaLatitude;
        double minLongitude = location.coordinate.longitude - deltaLongitude;
        double maxLongitude = location.coordinate.longitude + deltaLongitude;
        
        // Edit the predicate as appropiate.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                          @"(%@ <= lng) AND (lng <= %@)"
                          @" AND (%@ <= lat) AND (lat <= %@)"
                          @" AND delete == NO"
                          @" AND creationDate>%@"
                        ,@(minLongitude), @(maxLongitude), @(minLatitude), @(maxLatitude),[NSDate dateWithTimeIntervalSinceNow:-72000]];
        [fetchRequest setPredicate:predicate];
        
        // Fault
        //[fetchRequest setIncludesPropertyValues:NO];
        
        //Batch size
        [fetchRequest setFetchBatchSize:25];
        
        // Fetched results controller
        NSFetchedResultsController *aFetchedResultsController  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate =self;
        _fetchedResultsController =aFetchedResultsController;
        
        // Internal properties
        _visibleRows = [[NSMutableArray alloc] init];
        _moveRows = [[NSMutableArray alloc] init];
        _insertRows = @0;
        _offset = @0;
    }
    return self;
}

-(void)becomeFaultingPosts{
    for (Post* post in self.fetchedResultsController.fetchedObjects) {
        [self.fetchedResultsController.managedObjectContext refreshObject:post mergeChanges:NO];
    }
}

#pragma mark - Public

//-(BOOL)loadData:(NSError *__autoreleasing *)error{
//    return [self.fetchedResultsController performFetch:error];
//}

-(BOOL)loadDataWithLocation:(CLLocation *)location error:(NSError *__autoreleasing *)error{
    double D = [[Preferences UserStepRadius] doubleValue] ;
    double R = 6371009.;
    double meanLatitidue = location.coordinate.latitude * M_PI / 180.;
    double deltaLatitude = D / R * 180. / M_PI;
    double deltaLongitude = D / (R * cos(meanLatitidue)) * 180. / M_PI;
    double minLatitude = location.coordinate.latitude - deltaLatitude;
    double maxLatitude = location.coordinate.latitude + deltaLatitude;
    double minLongitude = location.coordinate.longitude - deltaLongitude;
    double maxLongitude = location.coordinate.longitude + deltaLongitude;
    
    
    // Edit the predicate as appropiate.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(%@ <= lng) AND (lng <= %@)"
                              @" AND (%@ <= lat) AND (lat <= %@)"
                              @" AND delete == NO"
                              @" AND creationDate>%@"
                              ,@(minLongitude), @(maxLongitude), @(minLatitude), @(maxLatitude),[NSDate dateWithTimeIntervalSinceNow:-72000]];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    BOOL result=[self.fetchedResultsController performFetch:error];
    [self.tableView reloadData];
    return result;
}

-(Post *)postForIndexPath:(NSIndexPath *)indexPath{
    if (self.fetchedResultsController.fetchedObjects.count>indexPath.row) {
        return (Post*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    }else{
        return nil;
    }
}

-(NSInteger)numberOfPost{
    return [[self.fetchedResultsController fetchedObjects] count];
}

-(void)deletePostAtIndexPath:(NSIndexPath*)indexPath direction:(SNPostDirection)direction{
    self.directionToDelete = direction;
    self.deletePost = YES;
    Post* post = [self postForIndexPath:indexPath];
    post.delete = @YES;
}

#pragma mark - Post data source protocol

-(NSString *)name{
    switch ([self.sorted intValue]) {
        case SNPostSortByDate:
            return NSLocalizedString(@"post.sorted-by-date.title", nil);
        case SNPostSortByRate:
            return NSLocalizedString(@"post.sorted-by-rate.title", nil);
        default:
            return nil;
    }
}

-(NSString *)navigationBarName{
    switch ([self.sorted intValue]) {
        case SNPostSortByDate:
            return NSLocalizedString(@"post.sorted-by-date.title", nil);
        case SNPostSortByRate:
            return NSLocalizedString(@"post.sorted-by-rate.title", nil);
        default:
            return nil;
    }
}

-(UIImage *)tabBarImage{
    
    switch ([self.sorted intValue]) {
        case SNPostSortByDate:
            return [UIImage imageNamed:@"newsIcon"];
        case SNPostSortByRate:
            return [UIImage imageNamed:@"rateIcon"];
        default:
            return nil;
    }
}

-(void)setSorted:(NSNumber *)sorted{
    _sorted = sorted;
    switch ([self.sorted intValue]) {
        case SNPostSortByDate:{
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [self.fetchedResultsController.fetchRequest setSortDescriptors:sortDescriptors];
        }
            break;
        case SNPostSortByRate:{
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rate" ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [self.fetchedResultsController.fetchRequest setSortDescriptors:sortDescriptors];
        }
            break;
    }
}

#pragma mark - Data source protocol

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = [self.fetchedResultsController sections].count;
    if (count == 0) {
        count = 1;
    }
    return count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    if ([self.fetchedResultsController sections].count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    if (numberOfRows==0) {
        self.shouldShowBackground =@YES;
    }else{
        self.shouldShowBackground =@NO;
    }
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostBaseTableViewCell* cell;
    Post* post=[self postForIndexPath:indexPath];
    if (![post.photo isEqualToString:@""]) {
        if ([post.content isEqualToString:@""]) {
            cell = (PostBaseTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SN_POST_STYLE_PHOTO_CELL forIndexPath:indexPath];
            if (!cell) {
                cell =[[PostStylePhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_PHOTO_CELL];
            }else if (![cell isMemberOfClass:[PostStylePhotoTableViewCell class]]){
                cell =[[PostStylePhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_PHOTO_CELL];
            }
        }else{
            cell = (PostStylePhotoAndTextTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SN_POST_STYLE_PHOTO_TEXT_CELL forIndexPath:indexPath];
            if (!cell) {
                cell = [[PostStylePhotoAndTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_PHOTO_TEXT_CELL];
            }else if (![cell isMemberOfClass:[PostStylePhotoAndTextTableViewCell class]]){
                cell = [[PostStylePhotoAndTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_PHOTO_TEXT_CELL];
            }
        }
    }else{
        cell = (PostStyleTextTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SN_POST_STYLE_TEXT_CELL forIndexPath:indexPath];
        if (!cell) {
            cell = [[PostStyleTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_TEXT_CELL];
        }else if (![cell isMemberOfClass:[PostStyleTextTableViewCell class]]){
            cell = [[PostStyleTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SN_POST_STYLE_TEXT_CELL];
        }
    }
    if (cell.wowButton.allTargets && cell.wowButton.allTargets.count<1) {
        [cell.wowButton addTarget:self action:@selector(doWow:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PostBaseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Post *post = [self postForIndexPath:indexPath];
    cell.post = post;
}

#pragma mark - Custom accesors

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController==nil) {
        NSLog(@"%@",@"nil");
    }
    return _fetchedResultsController;
}

#pragma  mark - Fetched results controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.visibleRows = [NSMutableArray arrayWithArray:[self.tableView indexPathsForVisibleRows]];
    
    self.offset = @(self.tableView.contentOffset.y>0?self.tableView.contentOffset.y:0);
    
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    float totalOffset = 0;
    float rowHeight = self.tableView.rowHeight;
    totalOffset = [self.offset floatValue] + [self.insertRows floatValue]*rowHeight;
    
    int maxVisibleRow = 0;
    for (NSIndexPath* visibleRow in self.visibleRows ) {
        maxVisibleRow = (int)MAX(visibleRow.row , maxVisibleRow);
    }
    int numberOfMovements = 0 ;
    for (NSNumber* beforeIndexPathRow in self.moveRows) {
        if ([beforeIndexPathRow intValue]>=maxVisibleRow) {
            numberOfMovements++;
        }
    }
    
    totalOffset += numberOfMovements*rowHeight;
    float totalRows= (float)[self tableView:self.tableView numberOfRowsInSection:0];
    totalOffset = totalOffset>totalRows*rowHeight?totalRows*rowHeight:totalOffset;
    
    NSLog(@"%f",totalOffset);
    
    if (self.deletePost) {
        [self.tableView setContentOffset:CGPointMake(0, totalOffset) animated:YES];
        [self.tableView endUpdates];
        self.deletePost = NO;
    }else{
        [self.tableView endUpdates];
        [self.tableView setContentOffset:CGPointMake(0, totalOffset) animated:YES];
    }
    
    
    NSLog(@"%@",@"End change");
    if ([self.insertRows intValue]>0 || self.moveRows.count>0) {
        self.thereIsNewPost = @YES;
    }
    self.visibleRows = [[NSMutableArray alloc] init];
    self.moveRows = [[NSMutableArray alloc] init];
    self.insertRows = @0;
    self.offset = @0;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            NSLog(@"%@ %ld %ld",@"Insert",(long)indexPath.row,(long)newIndexPath.row);
            self.insertRows = @([self.insertRows integerValue]+1);
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            NSLog(@"%@ %ld %ld",@"Delete",(long)indexPath.row,(long)newIndexPath.row);
            switch (self.directionToDelete) {
                case SNPostLeft:
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    break;
                case SNPostRight:
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                    break;
                default:
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    break;
            }
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            NSLog(@"%@ %ld %ld",@"Update",(long)indexPath.row,(long)newIndexPath.row);
            [self configureCell:(PostBaseTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            NSLog(@"%@ %ld %ld",@"Move",(long)indexPath.row,(long)newIndexPath.row);
            [self.moveRows addObject:@(indexPath.row)];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

#pragma mark - Helpers

-(IBAction)doWow:(id)sender forEvent:(UIEvent*)event{
    //UIButton* button = (UIButton*)sender;
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    Post *post = (Post *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (![post.like boolValue]) {
        PostBaseTableViewCell* cell = (PostBaseTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell startAnimation];
        post.rate = [NSNumber numberWithInt:[post.rate intValue]+1];
        post.like = @YES;
        PostSortedByDateDataSource* __weak weakSelf= self;
        [[SNPostResourceManager sharedManager] wowPostWithIDAccount:[Account accountId] idPost:post.idPost date:[NSDate date] success:^(ResponseServer* response){
            
        } failure:^(NSError *error) {
            [weakSelf cancelSurprised];
            post.rate = [NSNumber numberWithInt:[post.rate intValue]-1];
            post.like=@NO;
        }];
    }
}

-(void)cancelSurprised{
    [[SNPostResourceManager sharedManager] cancelWow];
}

@end
