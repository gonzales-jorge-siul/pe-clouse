//
//  MyProfileTableViewController.m
//  SNApp
//
//  Created by Jorge Gonzales on 8/3/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "MyProfileTableViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Account.h"
#import "SNObjectManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+SNColors.h"
#import "SNAccountResourceManager.h"
#import "SNConstans.h"

@interface MyProfileTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property UIImagePickerController* imagePickerController;

@property (strong, nonatomic) UIView* editorContainer;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *photoAlbumButton;

@property(nonatomic,strong) UIImage* initialPhoto;
@property(nonatomic,strong) UIImage* originalPhoto;
@property(nonatomic,strong) UIImage* editedPhoto;

@property(nonatomic,strong) UIImageView* editorPhotoView;
@property(nonatomic,strong) UIActivityIndicatorView* activityIndicator;

@property(nonatomic)CGFloat scale;
@property(nonatomic)CGFloat zoomScale;

@property(nonatomic,strong)Account* account;

@property(nonatomic,getter=isEditing)BOOL editing;


@property(nonatomic,strong)NSMutableSet* indexes;

@property(nonatomic,weak)UITextField* textField;

@property(nonatomic)BOOL newPhoto;

@property(nonatomic,strong)NSMutableArray* oldData;

@end

@implementation MyProfileTableViewController

NSString* const SNMyProfileCell = @"My Profile Cell";

NSUInteger const NUMBER_OF_SECTIONS = 2;
NSUInteger const NUMBER_OF_ROWS_SECTION_ONE = 3;

NSUInteger const NUMBER_OF_ROWS_SECTIONS_TWO = 1;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getMainAccount];
    [self setupInitialView];
    
    self.indexes = [NSMutableSet set];
    self.newPhoto = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    if (!parent) {
        [self saveContext];
    }
}
#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 5, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
            
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 6.0;
    }
    
    return 1.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return NUMBER_OF_SECTIONS;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NUMBER_OF_ROWS_SECTION_ONE;
        case 1:
            return NUMBER_OF_ROWS_SECTIONS_TWO;
        default:
            return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MyProfileTableViewCell heightForText:[self contentForRowAtIndexPath:indexPath] frame:self.tableView.bounds];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyProfileTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SNMyProfileCell forIndexPath:indexPath];
    if (!cell) {
        cell = [[MyProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SNMyProfileCell];
    }
    
    cell.contentLabel.text = [self contentForRowAtIndexPath:indexPath];
    cell.titleLabel.text = [self titleForRowAtIndexPath:indexPath];
    if (self.isEditing) {
        cell.contentLabel.enabled = YES;
        cell.contentLabel.returnKeyType = UIReturnKeyNext;
        if (cell.contentLabel.allTargets.count<1) {
            [cell.contentLabel addTarget:self action:@selector(newData:) forControlEvents:UIControlEventEditingChanged];

        }
    }else{
        cell.contentLabel.enabled = NO;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        self.textField = cell.contentLabel;
        [self initializeTextFieldInputView];
    }
    
    [self.indexes addObject:indexPath];
    
    cell.contentLabel.tag = [self tagForCellAtIndexPath:indexPath];
    
    return cell;
}

-(void)newData:(UITextField*)sender{
    switch (sender.tag) {
        case 0:
            self.account.name = sender.text;
            break;
        case 1:
            self.account.status = sender.text;
            break;
        case 2:{
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat =@"yyyy-MM-dd";
            self.account.birth = [formatter dateFromString:sender.text];
            break;
        }
        case 3:
            self.account.likes = sender.text;
            break;
        default:
            break;
    }
}


- (void) initializeTextFieldInputView{
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-14];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-120];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [datePicker setMaximumDate:maxDate];
    [datePicker setMinimumDate:minDate];

    datePicker.backgroundColor = [UIColor whiteColor];
    [datePicker addTarget:self action:@selector(dateUpdated:) forControlEvents:UIControlEventValueChanged];
    self.textField.inputView = datePicker;
}

- (void) dateUpdated:(UIDatePicker *)datePicker {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.textField.text = [formatter stringFromDate:datePicker.date];
    self.account.birth = datePicker.date;
}

#pragma mark - Actions

-(IBAction)edit:(id)sender{
    //Avoid user make another animation to end this
    self.navigationController.navigationBar.userInteractionEnabled = NO;

    //newphot
    self.newPhoto = NO;
    
    //Change right bar button
    [self rightBarButton:1];
    
    //Set current photo to edition
    [self setImageToEdit:self.imageView.image];
    
    MyProfileTableViewController* __weak weakSelf = self;
    //Start animation
    [self performAnimationFromView:self.imageView toView:self.scrollView containerView:self.editorContainer completionBlock:^(BOOL finished) {
        //Add edition buttons
        [weakSelf.editorContainer addSubview:weakSelf.cameraButton];
        [weakSelf.editorContainer addSubview:weakSelf.photoAlbumButton];
        
        //Allow interaction
        weakSelf.navigationController.navigationBar.userInteractionEnabled = YES;
        
        //Edition mode on
        weakSelf.editing = YES;
        
        [weakSelf.tableView reloadData];
    }];
    
    
}

-(IBAction)save:(id)sender{
    //Avoid user make another animation to end this
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    //Get new image
    self.editedPhoto = [self cropImage:self.originalPhoto zoomScale:self.zoomScale scale:self.scale offset:self.scrollView.contentOffset];
    
    //Change right bar button
    [self rightBarButton:0];
    
    //Send new data to server
    [self uploadData];
    MyProfileTableViewController* __weak weakSelf = self;
    //Start animation
    [self performAnimationFromView:self.scrollView toView:self.imageView containerView:self.editorContainer completionBlock:^(BOOL finished) {
        //Remove edition buttons
        [weakSelf.cameraButton removeFromSuperview];
        [weakSelf.photoAlbumButton removeFromSuperview];
        
        //Allow interaction
        weakSelf.navigationController.navigationBar.userInteractionEnabled = YES;
        
        //Edition mode off
        weakSelf.editing = NO;
        
        //
        [weakSelf.tableView reloadData];
    }];
}

-(void)performAnimationFromView:(UIView*)fromView toView:(UIView*)toView containerView:(UIView*)containerView completionBlock:(void(^)(BOOL finished))completion{
    CGRect startFrame = containerView.frame;
    CGRect endFrame = containerView.frame;
    
    // the start position is below the left of the visible frame
    startFrame.origin.x = -startFrame.size.width;
    endFrame.origin.x = 0;
    
    toView.frame = startFrame;
    [containerView addSubview:toView];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:0.5f options:0 animations:^{
        toView.frame = endFrame;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    }];
}


-(IBAction)showPhotoAlbum:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.navigationBarHidden = NO;
    imagePickerController.hidesBottomBarWhenPushed = YES;
    imagePickerController.toolbarHidden = YES;
    imagePickerController.mediaTypes = @[(NSString*)kUTTypeImage];
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(IBAction)showCamera:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.navigationBarHidden = YES;
    imagePickerController.hidesBottomBarWhenPushed = YES;
    imagePickerController.toolbarHidden = YES;
    imagePickerController.mediaTypes = @[(NSString*)kUTTypeImage];
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Image picker controller delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (info[UIImagePickerControllerOriginalImage]) {
        [self setImageToEdit:info[UIImagePickerControllerOriginalImage]];
        self.newPhoto = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Scroll view delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.editorPhotoView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.zoomScale = scale;
}

#pragma mark - Helpers

-(void)setupInitialView{
    //Navigation controller setup
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    //Photo editor setup
    [self.editorContainer addSubview:self.imageView];
    
    //Table view
    self.tableView.tableHeaderView = self.editorContainer;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.backgroundColor = [UIColor gray200Color];
    
    //Account photo
    if ([self.account.photo isEqualToString:@""]) {
        [self.imageView setImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
        self.initialPhoto = [UIImage imageNamed:@"emptyPhotoUserIcon"];
    }else{
        [self.imageView setImageWithURL:[NSURL URLWithString:self.account.photo] placeholderImage:[UIImage imageNamed:@"whiteBackground"]];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.account.photo] ];
        
        MyProfileTableViewController* __weak weakSelf = self;
        
        [self.imageView setImageWithURLRequest:request  placeholderImage:[UIImage imageNamed:@"whiteBackground"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.imageView.image = image;
            weakSelf.initialPhoto = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.imageView.image = [UIImage imageNamed:@"whiteBackground"];
            weakSelf.initialPhoto = [UIImage imageNamed:@"whiteBackground"];
        }];
    }
    
    //Initial right bar button
    [self rightBarButton:0];
}

-(void)rightBarButton:(NSUInteger)item{
    switch (item) {
        case 0:{
            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"myprofile.navigation-bar.Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(edit:)];
            [self.navigationItem setRightBarButtonItem:item animated:YES];
            break;
        }
        case 1:{
            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"myprofile.navigation-bar.Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
            [self.navigationItem setRightBarButtonItem:item animated:YES];
            break;
        }
    }
}

-(UIImage*)cropImage:(UIImage*)image zoomScale:(CGFloat)zoomScale scale:(CGFloat)scale offset:(CGPoint)offset{
    if (!self.newPhoto && zoomScale==1 && image.size.width == image.size.height) {
        return image;
    }
    UIImage* returnImage;

    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
   
    CGFloat newDimension = MIN(width, height);
    CGFloat widthOffset = offset.x/(scale*zoomScale);
    CGFloat heightOffset = offset.y/(scale*zoomScale);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension/zoomScale, newDimension/zoomScale), YES, 0.);
    [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset) blendMode:kCGBlendModeCopy alpha:1.];
    returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect cropRect = CGRectMake(0 ,0 ,600 ,600);
    
    UIGraphicsBeginImageContextWithOptions(cropRect.size,YES , 1.0f);
    [returnImage drawInRect:cropRect];
    returnImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return returnImage;
}

-(NSString*)titleForRowAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return NSLocalizedString(@"profile.category.name", nil);
                case 1:
                    return NSLocalizedString(@"profile.category.status", nil);
                case 2:
                    return NSLocalizedString(@"profile.category.birth", nil);
                default:
                    return @"";
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return NSLocalizedString(@"profile.category.likes", nil);
                default:
                    return @"";
            }
        default:
            return @"";
    }
}

-(NSString*)contentForRowAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return self.account.name;
                case 1:
                    return self.account.status;
                case 2:{
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    return [formatter stringFromDate:self.account.birth];
                }
                default:
                    return @"";
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return self.account.likes;
                default:
                    return @"";
            }
        default:
            return @"";
    }
}

-(NSString*)oldContentForRowAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return self.oldData[0];
                case 1:
                    return self.oldData[1];
                case 2:{
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    return [formatter stringFromDate:self.oldData[2]];
                }
                default:
                    return @"";
            }
        case 1:
            switch (indexPath.row) {
                case 0:
                    return self.oldData[3];
                default:
                    return @"";
            }
        default:
            return @"";
    }

}

-(int)tagForCellAtIndexPath:(NSIndexPath*)indexPath{
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                    return 0;
                case 1:
                    return 1;
                case 2:
                    return 2;
                default:
                    return -1;
            }
        }
        case 1:{
            switch (indexPath.row) {
                case 0:
                    return 3;
                default:
                    return -1;
            }
        }
        default:
            return -1;
    }
}

-(void)getMainAccount{
    NSManagedObjectContext *context = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Account"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@",
                              [Account username]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
    }
    if (fetchedObjects.count == 1) {
        [self setAccount:fetchedObjects[0]];
    }
}

-(void)setImageToEdit:(UIImage*)image{
    self.originalPhoto = image;
    self.editedPhoto = image;
    
    self.scale = 1;
    self.zoomScale = 1;
    
    if (self.originalPhoto.size.height>=self.originalPhoto.size.width) {
        self.scale = self.tableView.bounds.size.width/self.originalPhoto.size.width;
    }else{
        self.scale = self.tableView.bounds.size.width/self.originalPhoto.size.height;
    }
    CGRect frame = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width);
    frame.size.height = self.originalPhoto.size.height*self.scale;
    frame.size.width = self.originalPhoto.size.width*self.scale;
    [self.editorPhotoView setFrame:frame];
    self.scrollView.contentSize = self.editorPhotoView.frame.size;
    
    self.editorPhotoView.image = self.originalPhoto;
}


-(void)uploadData{
    NSNull* null = [NSNull null];
    NSMutableArray* dataToUpdate= [NSMutableArray arrayWithArray:@[null,null,null,null,null]];
    
    if (![self image:self.originalPhoto isEqualTo:self.editedPhoto]) {
        //Show activity indicator
        [self.activityIndicator startAnimating];
        //Change image
        self.imageView.image = [UIImage imageNamed:@"whiteBackground"];
        //Save photo in photoalbum and return an URL
        dataToUpdate[0] = [self savePhoto:self.editedPhoto];
    }
    
    for (NSIndexPath* indexPath in self.indexes) {
        NSString* newContent = [self contentForRowAtIndexPath:indexPath];
        NSString* oldContent = [self oldContentForRowAtIndexPath:indexPath];
        
        if ([newContent isEqualToString:oldContent]) {
            continue;
        }
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        dataToUpdate[1] = newContent;
                        self.account.name = newContent;
                        break;
                    case 1:
                        dataToUpdate[2] = newContent;
                        self.account.status = newContent;
                        break;
                    case 2:{
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        if ([newContent isEqualToString:@""]) {
                            newContent=@"0001-01-01";
                        }
                        NSDate *date = [dateFormatter dateFromString:newContent];
                        dataToUpdate[3] = date;
                        self.account.birth = date;
                        break;
                    }
                }
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        dataToUpdate[4] = newContent;
                        self.account.likes = newContent;
                        break;
                }
                break;
        }
    }
    //Ask if should update data
    BOOL shouldUpdate = NO;
    for (id object in dataToUpdate) {
        if (object!=null) {
            shouldUpdate = YES;
            break;
        }
    }
    
    if (shouldUpdate) {
        MyProfileTableViewController* __weak weakSelf = self;
        [[SNAccountResourceManager sharedManager] updateAccountName:dataToUpdate[1]!= null?dataToUpdate[1]:self.account.name status:dataToUpdate[2]!=null?dataToUpdate[2]:self.account.status birth:dataToUpdate[3]!=null?dataToUpdate[3]:self.account.birth likes:dataToUpdate[4]!=null?dataToUpdate[4]:self.account.likes photo:dataToUpdate[0]!=null?dataToUpdate[0]:nil username:[Account username] success:^(ResponseServer *response) {
            //Save recieved URL
            if (![response.URLPhoto isEqualToString:@""]) {
                weakSelf.account.photo = response.URLPhoto;
            }
            //Stop animating
            [weakSelf.activityIndicator stopAnimating];
            //Show new photo
            weakSelf.imageView.image = weakSelf.editedPhoto;
        } failure:^(NSError *error) {
            //Stop animating
            [weakSelf.activityIndicator stopAnimating];
            //Show initial photo
            weakSelf.imageView.image = weakSelf.initialPhoto;
            
            //Cancel request
            [weakSelf cancelUpdateAccount];
            
            NSString* title ;
            NSString* message ;
            UIAlertAction *okAction ;
            
            if ([error.domain isEqualToString:SNSERVICES_ERROR_DOMAIN]) {
                switch (error.code) {
                    case SNNoInternet:
                        title = NSLocalizedString(@"app.error.no-internet-connection", nil);
                        message = NSLocalizedString(@"myprofile.alert.no internet message", nil);
                        okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:nil];
                        break;
                    case SNNoServer:
                        title = NSLocalizedString(@"app.error.no-server-connection", nil);
                        message = NSLocalizedString(@"myprofile.alert.no server message", nil);
                        okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"app.general.ok", nil) style:UIAlertActionStyleDefault handler:nil];
                        break;
                }
            }
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:okAction];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }];
    }
}

-(void)cancelUpdateAccount{
    [[SNAccountResourceManager sharedManager] cancelUpdateAccount];
}

-(NSURL*)savePhoto:(UIImage*)photo{
    
    NSString* photos=@"Photos";
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSURL* pathDirectory;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'_at_'HH:mm:ss"];
    NSString* photoName = [NSString stringWithFormat:@"%@%@%@",@"SNApp",[dateFormatter stringFromDate:[NSDate date]],@".jpeg"];
    
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    if (tmpDirURL) {
        pathDirectory=[tmpDirURL URLByAppendingPathComponent:photos];
        //If the folder doesn't exist create it
        if (![sharedFM fileExistsAtPath:pathDirectory.path]) {
            NSError* error;
            if (![sharedFM createDirectoryAtURL:pathDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"%@",@"Can't create directory");
                return nil;
            }else{
                UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
                NSURL *photoPath = [pathDirectory URLByAppendingPathComponent:photoName];
                if (![UIImageJPEGRepresentation(photo, 0.2) writeToURL:photoPath atomically:YES]) {
                    NSLog(@"%@",@"Can't add photo");
                    return nil;
                }
                return photoPath;
            }
        }else{
            UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
            NSURL *photoPath = [pathDirectory URLByAppendingPathComponent:photoName];
            if (![UIImageJPEGRepresentation(photo, 0.2) writeToURL:photoPath atomically:YES]) {
                NSLog(@"%@",@"Can't add photo");
                return nil;
            }
            return photoPath;
        }
    }else{
        return nil;
    }
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = [[[SNObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext saveToPersistentStore:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

#pragma mark - Custom accessors

-(UIView *)editorContainer{
    if (!_editorContainer) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width)];
        _editorContainer = view;
    }
    return _editorContainer;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rateIcon"]];
        [view setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width)];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.activityIndicator];
        _imageView = view;
    }
    _imageView.contentMode = UIViewContentModeScaleToFill;
    return _imageView;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView* view  = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width)];
        view.backgroundColor = [UIColor blackColor];
        view.alwaysBounceHorizontal =YES;
        view.alwaysBounceVertical = YES;
        view.minimumZoomScale = 1.0;
        view.maximumZoomScale = 8.0;
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.delegate = self;
        
        
        [view addSubview:self.editorPhotoView];
        _scrollView = view;
    }
    return _scrollView;
}

-(UIButton *)cameraButton{
    if (!_cameraButton) {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width - 52 - 8, self.tableView.bounds.size.width - 52 -8, 52,52)];
        [button addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        button.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [button setImage:[UIImage imageNamed:@"cameraEditIcon"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
        button.layer.cornerRadius = 8.f;
        button.clipsToBounds = YES;
        _cameraButton =  button;
    }
    return _cameraButton;
}

-(UIButton *)photoAlbumButton{
    if (!_photoAlbumButton) {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width - 8 - 52 -8 -52, self.tableView.bounds.size.width - 8 -52, 52, 52)];
        [button addTarget:self action:@selector(showPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        button.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [button setImage:[UIImage imageNamed:@"photoalbumEditIcon"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
        button.layer.cornerRadius = 8.f;
        button.clipsToBounds = YES;
        _photoAlbumButton = button;
    }
    return _photoAlbumButton;
}

-(UIImageView *)editorPhotoView{
    if (!_editorPhotoView) {
        UIImageView* view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.width)];
        view.contentMode = UIViewContentModeScaleToFill;
        _editorPhotoView = view;
    }
    _editorPhotoView.contentMode = UIViewContentModeScaleToFill;
    return _editorPhotoView;
}

-(UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        UIActivityIndicatorView* view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGFloat center =self.view.bounds.size.width/2.0f;
        view.center = CGPointMake(center,center);
        view.color = [UIColor grayColor];
        view.hidesWhenStopped = YES;
        _activityIndicator = view;
    }
    return _activityIndicator;
}
-(void)setAccount:(Account *)account{
    _account = account;
    if (!self.oldData) {
        self.oldData = [NSMutableArray array];
    }
    [self.oldData addObject:self.account.name];
    [self.oldData addObject:self.account.status];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-150];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [self.oldData addObject:self.account.birth?self.account.birth:maxDate];
    [self.oldData addObject:self.account.likes];
}

@end
