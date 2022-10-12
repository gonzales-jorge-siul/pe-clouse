//
//  AddPostViewController.h
//  SNApp
//
//  Created by Force Close on 6/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPostProtocol;

@interface AddPostViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic,weak)id<AddPostProtocol> delegate;

@end

@protocol AddPostProtocol <NSObject>

-(void)didDone:(BOOL)done;

@end
