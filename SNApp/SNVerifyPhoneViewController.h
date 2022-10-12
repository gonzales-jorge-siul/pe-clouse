//
//  SNVerifyPhoneViewController.h
//  SNApp
//
//  Created by Force Close on 8/9/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVerifyPhoneViewController : UIViewController

@property(strong,nonatomic)NSString* phoneNumber;
@property(strong,nonatomic)NSString* activationCode;
@property(strong,nonatomic)NSString* accountExist;

@end

@protocol SNTextViewDelegate <UITextFieldDelegate>

- (void) textFieldDeleteBackward:(UITextField*)textField;

@end

@interface SNTextField : UITextField

@property(weak, nonatomic) id<SNTextViewDelegate> delegate;

@end