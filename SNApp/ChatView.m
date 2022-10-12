//
//  ChatView.m
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import "ChatView.h"
#import "UIColor+SNColors.h"

@interface ChatView ()

@property(nonatomic,strong)UIToolbar* toolBar;
@property(atomic)CGSize keyboardSize;

@end

@implementation ChatView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        
        //Table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 , frame.size.width, frame.size.height-TOOLBAR_HEIGHT_CHAT)];
        _tableView.allowsSelection=YES;
        _tableView.allowsMultipleSelection=NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor gray200Color];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self addSubview:_tableView];
        
        //Text toolbar
        _text =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.8, TOOLBAR_HEIGHT_CHAT-2*TEXT_UPPER_MARGIN_CHAT)];
        _text.placeholder = NSLocalizedString(@"chat.texfield-message.placeholder.Type a message", nil);
        _text.borderStyle = UITextBorderStyleNone;
        _text.font = [UIFont systemFontOfSize:15];
        [_text addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithCustomView:_text];
        
        //Button toolbar
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOLBAR_HEIGHT_CHAT, TOOLBAR_HEIGHT_CHAT)];
        [_button setImage:[UIImage imageNamed:@"sendIcon"] forState:UIControlStateNormal];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc]initWithCustomView:_button];
        
        //Flexible space
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //Toolbar
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toolBar.barTintColor =[UIColor whiteColor];
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"whiteBackground"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolBar setItems:@[item1,flexibleItem,item2]] ;
        [self addSubview:_toolBar];
        
        self.backgroundColor = [UIColor gray200Color];
        
        //Register for keyboard notifications
        [self registerForKeyboardNotifications];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.toolBar setFrame:[self _toolBarFrame]];
    [self.tableView setFrame:[self _tableViewFrame]];
}

-(CGRect)_tableViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-TOOLBAR_HEIGHT_CHAT-self.keyboardSize.height );
}

-(CGRect)_toolBarFrame{
    return CGRectMake(0,self.bounds.size.height-TOOLBAR_HEIGHT_CHAT-self.keyboardSize.height,self.bounds.size.width, TOOLBAR_HEIGHT_CHAT);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Constants

//ToolBar
CGFloat const TOOLBAR_HEIGHT_CHAT=44;
//Text
CGFloat const TEXT_UPPER_MARGIN_CHAT =4;

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
    NSDictionary* userInfo  = [aNotification userInfo];
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double kbAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //Computing keyboardSize in current view
    self.keyboardSize = kbFrame.size;
    
    ChatView* __weak weakSelf = self;
    
    //Table view
    [UIView animateWithDuration:kbAnimationDuration animations:^{
        [weakSelf.tableView setFrame:[weakSelf _tableViewFrame]];
    }];
    [self.tableView scrollRectToVisible:[self.tableView.tableFooterView frame] animated:YES];
    
    //ToolBar
    [UIView animateWithDuration:kbAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    NSDictionary* userInfo  = [aNotification userInfo];
//    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double kbAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //Computing keyboardSize in current view
    self.keyboardSize = CGRectZero.size;
    
    ChatView* __weak weakSelf = self;
    
    //Table view
    [UIView animateWithDuration:kbAnimationDuration animations:^{
        [weakSelf.tableView setFrame:[weakSelf _tableViewFrame]];
    }];
    
    //ToolBar
    [UIView animateWithDuration:kbAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    }];
    
}

#pragma mark - Actions

-(IBAction)textChanged:(UITextField*)sender{
    if ([sender.text isEqualToString:@" "]) {
        sender.text =@"";
    }
}
@end
