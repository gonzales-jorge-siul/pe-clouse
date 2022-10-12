//
//  CommentListView.m
//  SNApp
//
//  Created by Force Close on 6/30/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "CommentListView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+SNColors.h"
#import <QuartzCore/QuartzCore.h>

#import "StatisticsFrameView.h"

@interface CommentListView ()<UITextFieldDelegate>

@property(nonatomic,strong)UIToolbar* toolBar;
@property(atomic)CGSize keyboardSize;
@property(nonatomic,strong)UIImageView* photo;
@property(nonatomic,strong)UIView* photoContainer;
@property(nonatomic,strong)UILabel* content;
@property(nonatomic,strong)UIView* contentPost;

@property(nonatomic,strong)StatisticsFrameView* statisticsView;

@end

@implementation CommentListView
#pragma mark - Life cycle
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //Table view
        //_tableView =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-TOOLBAR_HEIGHT_COMMENT_LIST) style:UITableViewStyleGrouped];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-TOOLBAR_HEIGHT_COMMENT_LIST)];
        _tableView.allowsSelection=YES;
        _tableView.allowsMultipleSelection=NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.backgroundColor = [UIColor gray200Color];
        
        [self addSubview:_tableView];
        
        //Text toolbar
        _commentText =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.7, TOOLBAR_HEIGHT_COMMENT_LIST-2*TEXT_UPPER_MARGIN_COMMENT_LIST)];
        _commentText.placeholder = NSLocalizedString(@"comment.texfield-message.placeholder.Add a comment", nil);
        _commentText.borderStyle = UITextBorderStyleNone;
        _commentText.font = [UIFont systemFontOfSize:14.f];
        [_commentText addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithCustomView:_commentText];
        
        //Button toolbar (item 2)
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDHT_SEND_BUTTON_CLV, HEIGHT_SEND_BUTTON_CLV)];
        [_sendButton setImage:[UIImage imageNamed:@"sendIcon"] forState:UIControlStateNormal];
        _sendButton.contentMode = UIViewContentModeScaleToFill;
        [_sendButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, -15)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc]initWithCustomView:_sendButton];
        
        //Flexible space
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //Toolbar
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"whiteBackground"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        _toolBar.opaque = YES;
        _toolBar.tag =12;
        [_toolBar setItems:@[item1,flexibleItem,item2]] ;
        [self addSubview:_toolBar];
        
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
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Constants
//ToolBar
CGFloat const TOOLBAR_HEIGHT_COMMENT_LIST=44.0;
//SendButton
CGFloat const HEIGHT_SEND_BUTTON_CLV=44;
CGFloat const WIDHT_SEND_BUTTON_CLV=44;
//Text
CGFloat const TEXT_UPPER_MARGIN_COMMENT_LIST =4.0;
//Content
CGFloat const UPPER_MARGIN_CONTENT = 8.0;
CGFloat const LEFT_MARGIN_CONTENT = 14.0;

#pragma mark - Helpers
-(CGRect)_tableViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-TOOLBAR_HEIGHT_COMMENT_LIST);
}
-(CGRect)_toolBarFrame{
    return CGRectMake(0,self.bounds.size.height-TOOLBAR_HEIGHT_COMMENT_LIST-self.keyboardSize.height,self.bounds.size.width, TOOLBAR_HEIGHT_COMMENT_LIST);
}
-(CGSize)_contentTextSize:(NSString*)text{
    return [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 2*LEFT_MARGIN_CONTENT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.content.font} context:nil].size;
}
-(CGFloat)_contentTextSizeFont:(NSString*)text{
    if (text.length <=25) {
        return 40.0;
    }else if(text.length <=100){
        return 20.0;
    }else{
        return 20.0;
    }
}

#pragma mark - Custom accessors

-(void)setPost:(Post *)post{
    _post = post;
    
    CGFloat height =self.tableView.bounds.size.width;
    
    if (![_post.photo isEqualToString:@""]) {
        
        //Request photo
        [self.photo setImageWithURL:[NSURL URLWithString:_post.photo] placeholderImage:[UIImage imageNamed:@"whiteBackground"]];
        
        //Set content when there's a photo
        self.content.font = [UIFont systemFontOfSize:16.0];
        CGSize contentTextSize = [self _contentTextSize:_post.content];
        [self.content setFrame:CGRectMake(LEFT_MARGIN_CONTENT, self.photo.bounds.size.height+UPPER_MARGIN_CONTENT,self.tableView.bounds.size.width -2*LEFT_MARGIN_CONTENT, contentTextSize.height)];
        self.content.text = _post.content;
        self.content.textAlignment = NSTextAlignmentLeft;
        self.content.textColor = [UIColor blackColor];
        if (![self.post.content isEqualToString:@""]) {
         height += contentTextSize.height+UPPER_MARGIN_CONTENT*2;
        }
    }else{
        [self.photo setImage:[UIImage imageNamed:@"whiteBackground"]];
        
        //Set content when there isn't a photo
        self.content.font = [UIFont systemFontOfSize:[self _contentTextSizeFont:_post.content]];
        [self.content setFrame:CGRectMake(0, 0,self.photo.bounds.size.width, self.photo.bounds.size.height)];
        self.content.textAlignment = NSTextAlignmentCenter;
//        self.content.textColor = [UIColor gray800Color];
        
        NSString* contentText = [NSString stringWithFormat:@"\"%@\"",self.post.content];
        NSRange startRange = NSMakeRange(0, 1);
        NSRange endRange = NSMakeRange(contentText.length-1, 1);
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithString:contentText];
        [attributeContent addAttribute:NSForegroundColorAttributeName value:[UIColor appMainColor] range:startRange];
        [attributeContent addAttribute:NSForegroundColorAttributeName value:[UIColor appMainColor] range:endRange];
        self.content.attributedText = attributeContent;
    }
    
    //Set statistics
    self.statisticsView.distance = self.post.distance;
    self.statisticsView.creationDate = self.post.creationDate;
    self.statisticsView.numberOfComments = self.post.numComment;
    self.statisticsView.numberOfSurprised = self.post.rate;
    self.statisticsView.surprised = self.post.like;
    
    //Add container post to table header
    [self.contentPost setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, height)];
    [self.tableView setTableHeaderView:self.contentPost];

    //Reset comment
    self.commentText.text = @"";

}

-(UIImageView *)photo{
    if (!_photo) {
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width,self.tableView.bounds.size.width )];
        //image.layer.shadowColor = [UIColor blackColor].CGColor;
        //image.layer.shadowOffset =  CGSizeMake(1,0);
        //image.layer.shadowOpacity = 0.5;
        //image.clipsToBounds = NO;
        image.userInteractionEnabled = YES;
        [image addSubview:self.photoContainer];
        _photo = image;
    }
    return _photo;
}

-(UIView*)photoContainer{
    if (!_photoContainer) {
        UIView* view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width,self.tableView.bounds.size.width )];
        view.backgroundColor = [UIColor clearColor];
        [self addGradientToView:view];
        _photoContainer = view;
    }
    return _photoContainer;
}

-(UILabel *)content{
    if (!_content) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
        _content = label;
    }
    return _content;
}

-(UIView *)contentPost{
    if (!_contentPost) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.photo];
        [view addSubview:self.content];
        _contentPost =view;
    }
    return _contentPost;
}

-(StatisticsFrameView *)statisticsView{
    if (!_statisticsView) {
        StatisticsFrameView* view  = [[StatisticsFrameView alloc] initWithFrame:CGRectMake(0, self.tableView.bounds.size.width - 52, self.tableView.bounds.size.width, 52) style:SNStatisticsStyleAppColorTransluce];
        [self.photo addSubview:view];
        self.surprisedButton = view.surprisedButton;
        _statisticsView = view;
    }
    return _statisticsView;
}

#pragma mark - Helpers

- (void)addGradientToView:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.bounds.size.width, 20);
    gradient.colors = @[(id)[[[UIColor blackColor] colorWithAlphaComponent:0.25] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    [view.layer insertSublayer:gradient atIndex:0];
}

-(void)deleteBlankSpaces{
    NSString *rawString = [self.commentText text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length]==0) {
        self.commentText.text = @"";
    }
}

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
    CGRect  kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect  kbSize =[self convertRect:kbFrame fromView:nil];
    //kbSize.size.height=kbSize.size.height-(kbFrame.origin.y-kbSize.origin.y-14);
    self.keyboardSize = kbSize.size;
    
    double keyboardAnimationDuration=[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CommentListView* __weak weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    }];
    
    //[self setNeedsLayout];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    self.keyboardSize = CGRectZero.size;
    double keyboardAnimationDuration=[[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CommentListView* __weak weakSelf = self;
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        [weakSelf.toolBar setFrame:[weakSelf _toolBarFrame]];
    }];
}

#pragma mark - Action

-(IBAction)textChanged:(id)sender{
    if (self.commentText.text.length ==1) {
        [self deleteBlankSpaces];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return NO;
}

@end
