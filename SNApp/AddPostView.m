//
//  AddPostView.m
//  SNApp
//
//  Created by Force Close on 6/24/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "AddPostView.h"
#import "UIColor+SNColors.h"

@interface AddPostView ()

@property (nonatomic,strong) UIToolbar* toolBar;
@property (nonatomic,strong) UIScrollView* scrollView;

@property(atomic)CGSize keyboardSize;

@end

@implementation AddPostView

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        //Create scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.alwaysBounceVertical = YES;
        [self addSubview:_scrollView];
        
        //Create textView
        _textView = [[SNTextViewUnderLine alloc] initWithFrame:CGRectZero];
        _textView.tag =12;
        _textView.maximumLetters = @200;
        [_scrollView addSubview:_textView];
        
        //Create ImageView
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.tag =13;
        _photoView.layer.cornerRadius =3.0;
        _photoView.clipsToBounds =YES;
        [_scrollView addSubview:_photoView];
        
        //Create Delete photo button
        _deletePhoto = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deletePhoto setImage:[UIImage imageNamed:@"deleteImageIcon"] forState:UIControlStateNormal];
        [_scrollView addSubview:_deletePhoto];
        
        //Create button in toolbar
        //Camera button
        _cameraButton =[UIButton buttonWithType:UIButtonTypeSystem];
        [_cameraButton setImage:[UIImage imageNamed:@"cameraIcon"] forState:UIControlStateNormal];
        [_cameraButton setFrame:CGRectMake(0, 0, 44, 44)];
        _cameraButton.tag =11;
        [_cameraButton setTintColor:[UIColor gray800Color]];
        
        UIBarButtonItem* _cameraButtonBarItem = [[UIBarButtonItem alloc] initWithCustomView:_cameraButton];
        UIBarButtonItem* flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem* flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //Create toolbar
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"whiteBackground"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        _toolBar.barTintColor = [UIColor whiteColor];
        _toolBar.items = @[flexibleSpaceLeft,_cameraButtonBarItem,flexibleSpaceRight];
        
        [self addSubview:_toolBar];
        [self registerForKeyboardNotifications];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.toolBar setFrame:[self _toolBarFrame]];
    [self.scrollView setFrame:[self _scrollViewFrame]];
    [self.textView setFrame:[self _textFrame]];
    [self.photoView setFrame:[self _imageFrame]];
    //NSLog(@"self photo: %f",self.photoView.bounds.size.height);
    [self.deletePhoto setFrame:[self _deletePhotoButtonFrame]];
    [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width, self.textView.bounds.size.height + self.photoView.bounds.size.height + UPPER_MARGIN_TEXT_FIELD*4 )];
}

static CGFloat const TOOLBAR_HEIGHT = 44.0;

static CGFloat const UPPER_MARGIN_TEXT_FIELD = 12.0;
static CGFloat const LEFT_MARGIN_TEXT_FIELD = 18.0;

static CGFloat const HEIGHT_DELETE_PHOTO_BUTON_AP= 44;
CGFloat const LEFT_MARGIN_PHOTO_VIEW_ADV = 16.0;

-(CGRect)_scrollViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-TOOLBAR_HEIGHT);
}

-(CGRect)_toolBarFrame{
    return CGRectMake(0,self.bounds.size.height-TOOLBAR_HEIGHT-self.keyboardSize.height,self.bounds.size.width , TOOLBAR_HEIGHT);
}

-(CGRect)_textFrame{
    CGFloat height = self.textView.bounds.size.height;
    return CGRectMake(LEFT_MARGIN_TEXT_FIELD, UPPER_MARGIN_TEXT_FIELD,self.bounds.size.width - 2*LEFT_MARGIN_TEXT_FIELD, height>30 ? height :  30);
}

-(CGRect)_imageFrame{
    return CGRectMake(LEFT_MARGIN_PHOTO_VIEW_ADV, [self _textFrame].size.height  + 3*UPPER_MARGIN_TEXT_FIELD, self.bounds.size.width-2*LEFT_MARGIN_PHOTO_VIEW_ADV, self.bounds.size.width-2*LEFT_MARGIN_PHOTO_VIEW_ADV);
}

-(CGRect)_deletePhotoButtonFrame{
    CGRect imageFrame = [self _imageFrame];
    return CGRectMake(imageFrame.origin.x + imageFrame.size.width - HEIGHT_DELETE_PHOTO_BUTON_AP/2.0f, imageFrame.origin.y-HEIGHT_DELETE_PHOTO_BUTON_AP/2.0f, HEIGHT_DELETE_PHOTO_BUTON_AP, HEIGHT_DELETE_PHOTO_BUTON_AP);
}

-(CGSize)_textSize{
    NSString* string = @"This";
    return [string boundingRectWithSize:CGSizeMake(self.bounds.size.width,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0] } context:nil].size;
}

#pragma mark - Custom accessors



#pragma mark - Keyboard

-(void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShown:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardSize = kbSize;
    
    double keyboardAnimationDuration=[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    AddPostView* __weak weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    } ];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    self.keyboardSize = CGRectZero.size;
    double keyboardAnimationDuration=[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    AddPostView* __weak weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    } ];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
