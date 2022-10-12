//
//  AddPostViewController.m
//  SNApp
//
//  Created by Force Close on 6/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "AddPostViewController.h"
#import "OverlayView.h"
#import "Preferences.h"
#import "SNPostResourceManager.h"
#import "SNConstans.h"
#import "UIColor+SNColors.h"
#import "SNTextViewUnderLine.h"
#import "AddPostView.h"
#import "Account.h"

@interface AddPostViewController ()

@property(nonatomic,strong)UIButton* cameraButton;
@property(nonatomic,strong)SNTextViewUnderLine* textView;
@property(nonatomic,strong)UIImageView* image;
@property(nonatomic,strong)UIImage* photo;
@property(nonatomic,strong)UIButton* deletePhotoButton;

@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@property(nonatomic,strong) OverlayView* overlayView;

@property(getter=isTakingPhoto)BOOL takingPhoto;

@property(nonatomic,strong)UIImage* tookPhoto;

@end

@implementation AddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self cameraAvailability];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(IBAction)addPost:(id)sender{
    if (![self canSubmitPost]) {
        return;
    }

    NSURL* path = nil;
    if (self.image.image) {
        path=[self savePhoto:self.image.image];
    }
    
    CLLocationCoordinate2D coordinate  = [Preferences UserLastPosition];
    [[SNPostResourceManager sharedManager] uploadPostWithURL:path withAccountId:[Account accountId] content:[self processText:self.textView.text] latitude:@(coordinate.latitude) longitude:@(coordinate.longitude) success:nil failure:nil];
    [self.textView resignFirstResponder];
    [self.delegate didDone:YES];
}

-(IBAction)cancelPost:(id)sender{
    [self.textView resignFirstResponder];
    [self.delegate didDone:NO];
}

-(IBAction)deletePhoto:(id)sender{
    self.photo = nil;
    self.image.image = nil;
    self.deletePhotoButton.alpha = 0.0;
}

-(IBAction)showCamera:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.navigationBarHidden = YES;
    imagePickerController.toolbarHidden =YES;
    imagePickerController.cameraFlashMode = [[Preferences CameraFlashMode] integerValue];
    imagePickerController.cameraDevice = [[Preferences CameraDevice] integerValue];
    self.overlayView =[[OverlayView alloc] initWithFrame:imagePickerController.cameraOverlayView.frame];
    [self.overlayView.shutterButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView.flashModeButton addTarget:self action:@selector(switchFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    switch ([[Preferences CameraFlashMode] integerValue]) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [self.overlayView.flashModeButton setImage:[UIImage imageNamed:@"flashModeAutomaticIcon"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            [self.overlayView.flashModeButton setImage:[UIImage imageNamed:@"flashModeOffIcon"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            [self.overlayView.flashModeButton setImage:[UIImage imageNamed:@"flashModeOnIcon"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self.overlayView.cameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView.backbutton addTarget:self action:@selector(dismissOverlayView:) forControlEvents:UIControlEventTouchUpInside];
    imagePickerController.cameraOverlayView =self.overlayView;
    self.overlayView = nil;
    self.imagePickerController = imagePickerController;
    self.takingPhoto = NO;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
-(IBAction)takePicture:(id)sender{
    if (!self.isTakingPhoto) {
        self.takingPhoto = YES;
        [self.imagePickerController takePicture];
    }
}
-(IBAction)switchFlashMode:(UIButton*)sender{
    switch (self.imagePickerController.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            self.imagePickerController.cameraFlashMode=UIImagePickerControllerCameraFlashModeOn;
            [Preferences setCameraFlashMode:[NSNumber numberWithInteger:UIImagePickerControllerCameraFlashModeOn]];
            [sender setImage:[UIImage imageNamed:@"flashModeOnIcon"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            self.imagePickerController.cameraFlashMode=UIImagePickerControllerCameraFlashModeAuto;
            [Preferences setCameraFlashMode:[NSNumber numberWithInteger:UIImagePickerControllerCameraFlashModeAuto]];
            [sender setImage:[UIImage imageNamed:@"flashModeAutomaticIcon"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            self.imagePickerController.cameraFlashMode=UIImagePickerControllerCameraFlashModeOff;
            [Preferences setCameraFlashMode:[NSNumber numberWithInteger:UIImagePickerControllerCameraFlashModeOff]];
            [sender setImage:[UIImage imageNamed:@"flashModeOffIcon"] forState:UIControlStateNormal];
            break;
    }
}
-(IBAction)switchCamera:(id)sender{
    switch (self.imagePickerController.cameraDevice) {
        case UIImagePickerControllerCameraDeviceRear:
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [Preferences setCameraFlashMode:[NSNumber numberWithInteger:UIImagePickerControllerCameraDeviceFront]];
            break;
        case UIImagePickerControllerCameraDeviceFront:
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            [Preferences setCameraFlashMode:[NSNumber numberWithInteger:UIImagePickerControllerCameraDeviceRear]];
            break;
    }
}
-(IBAction)dismissOverlayView:(id)sender{
    if (!self.isTakingPhoto) {
        [self finishAndUpdate];
    }
}

#pragma mark - Helpers

-(void)setupView{
    //Left bar button
    UIImage* image = [UIImage imageNamed:@"backArrowIcon"];
//    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [forwardButton setImage:image forState:UIControlStateNormal];
//    forwardButton.frame = CGRectMake(0, 0,22,22);
//    [[forwardButton imageView] setContentMode:UIViewContentModeScaleToFill];
////    CGFloat insetTop = (22 - image.size.height)/2.f;
////    CGFloat insetLeft = (22 - image.size.width)/2.f;
////    forwardButton.imageEdgeInsets = UIEdgeInsetsMake(insetTop>0?insetTop:0, insetLeft>0?insetLeft:0, insetTop>0?insetTop:0, insetLeft>0?insetLeft:0);
//    forwardButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    [forwardButton addTarget:self action:@selector(cancelPost:) forControlEvents:UIControlEventTouchUpInside];
//    
    NSString* text = NSLocalizedString(@"addpost.title", nil);
    CGFloat textSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]} context:nil].size.width;
//
//    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width + 8, 0, textSize, image.size.height)];
//    label.font = [UIFont boldSystemFontOfSize:16.5];
//    label.textColor = [UIColor whiteColor];
//    label.text = text;
//    
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width + textSize, image.size.height)];
//    [view addSubview:label];
//    [view addSubview:forwardButton];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, image.size.width + textSize + 15, image.size.height)];
    [button addTarget:self action:@selector(cancelPost:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, image.size.width - 35, 0, 0)];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.5]];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //Rigth bar button
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"addpost.navigation-bar.Post", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addPost:)];
    self.navigationItem.rightBarButtonItem = rightButton;

    //self.navigationItem.title = NSLocalizedString(@"addpost.title", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor appMainColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.cameraButton=[(AddPostView*)self.view cameraButton];
    [self.cameraButton addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    self.textView = (SNTextViewUnderLine*)[(AddPostView*)self.view textView];
    self.textView.placeholder = NSLocalizedString(@"addpost.textfield-message.placeholder.Add a post", nil);
    self.textView.font = [UIFont systemFontOfSize:16.0];
    
    self.image = [(AddPostView*)self.view photoView];
    
    self.deletePhotoButton = [(AddPostView*)self.view deletePhoto];
    self.deletePhotoButton.alpha = 0.0;
    [self.deletePhotoButton addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)cameraAvailability{
     if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        self.cameraButton.userInteractionEnabled= false;
    }
}

- (void)finishAndUpdate
{
    AddPostViewController* __weak weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            weakSelf.photo = nil;
            weakSelf.imagePickerController = nil;
        }];
    });
    
    if ([NSThread isMainThread]) {
        [self loadImage];
    }else{
        [self performSelectorOnMainThread:@selector(loadImage) withObject:nil waitUntilDone:YES];
    }
}

-(void)loadImage{
    if (self.photo) {
        [self.image setImage:self.photo];
        [self.image setNeedsDisplay];
        self.deletePhotoButton.alpha = 1.0;
    }
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
                NSURL *photoPath = [pathDirectory URLByAppendingPathComponent:photoName];
                if (![UIImageJPEGRepresentation(photo, 0.5) writeToURL:photoPath atomically:YES]) {
                    NSLog(@"%@",@"Can't add photo");
                    return nil;
                }
                return photoPath;
            }
        }else{
            NSURL *photoPath = [pathDirectory URLByAppendingPathComponent:photoName];
            if (![UIImageJPEGRepresentation(photo, 0.5) writeToURL:photoPath atomically:YES]) {
                    NSLog(@"%@",@"Can't add photo");
                return nil;
            }
            return photoPath;
        }
    }else{
        return nil;
    }
}

-(BOOL)canSubmitPost{
    return ![self isEmptyContentPhotoPost] || ![self isEmptyContentTextPost];
}
-(BOOL)isEmptyContentTextPost{
    NSString *rawString = [self.textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    return trimmed.length==0?YES:NO;
}
-(BOOL)isEmptyContentPhotoPost{
    return self.image.image?NO:YES;
}
-(NSString*)processText:(NSString*)text{
    NSString* toProcess;
    int count= (int)text.length;
    for (int i = 0 ; i<count ; i++) {
        toProcess=[text substringFromIndex:(text.length-1)];
        if ([toProcess isEqualToString:@" "]) {
            text = [text substringToIndex:text.length -1];
        }else{
            break;
        }
    }
    return text;
}

#pragma mark - UIImagePickerControllerDelegate
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *imageTook = [info valueForKey:UIImagePickerControllerOriginalImage];
    [(OverlayView*)self.imagePickerController.cameraOverlayView setImageCustom:imageTook];
    self.tookPhoto = imageTook;
    
    AddPostViewController* __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = weakSelf.tookPhoto;
        CGSize imageSize = image.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        if (width != height) {
            CGFloat newDimension = MIN(width, height);
            CGFloat widthOffset = (width - newDimension) / 2;
            CGFloat heightOffset = (height - newDimension) / 2;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), YES, 0.);
            [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                     blendMode:kCGBlendModeCopy
                         alpha:1.];
            image = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            CGRect cropRect = CGRectMake(0 ,0 ,650 ,650);
            UIGraphicsBeginImageContextWithOptions(cropRect.size,YES , 1.0f);
            [image drawInRect:cropRect];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }   
        
        weakSelf.photo =image;
        
        [weakSelf finishAndUpdate];
    });
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
