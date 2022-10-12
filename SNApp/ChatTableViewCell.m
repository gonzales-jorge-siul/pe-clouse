//
//  ChatTableViewCell.m
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "UIColor+SNColors.h"

@interface ChatTableViewCell ()

@property(nonatomic,strong)UILabel* messageView;
@property(nonatomic,strong)UILabel* date;
@property(nonatomic,strong)UIImageView* bubble;
@property(nonatomic,strong)UIImageView* sentMark;

@property(atomic)BOOL previousSelectedState;

@end

@implementation ChatTableViewCell

#pragma mark - Life cycle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //Bubble
        _bubble = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bubble];
        
        //Message text
        _messageView = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageView.font = [UIFont systemFontOfSize:FONT_SIZE_MESSAGE_VIEW_CTV];
        _messageView.textColor = [UIColor blackColor];
        _messageView.numberOfLines = 0;
        [_bubble addSubview:_messageView];
        
        //Date
        _date = [[UILabel alloc] initWithFrame:CGRectZero];
        _date.alpha = 0.0;
        _date.font = [UIFont systemFontOfSize:15.0];
        _date.textColor =[UIColor grayColor];
        _date.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_date];
        
        //Sent mark
        _sentMark = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sentMark.contentMode = UIViewContentModeScaleToFill;
        [_bubble addSubview:_sentMark];
        
        self.contentView.backgroundColor =[UIColor gray200Color];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    if (self.message) {
        switch ((SNTypeMessage)[self.message.type integerValue]) {
            case SNReceiver:{
                [self.bubble setFrame:[self _bubbleFrame]];
                [self.messageView setFrame:[self _messageViewFrame]];
                [self.date setFrame:[self _dateViewFrame]];
                break;
            }
            case SNSender:{
                [self.bubble setFrame:[self _bubleFrameRight]];
                [self.messageView setFrame:[self _messageViewRightFrame]];
                [self.date setFrame:[self _dateViewRightFrame]];
                [self.sentMark setFrame:[self _sentMarkRightFrame]];
                break;
            }
        }
    }
}

#pragma mark - Constants

//Bubble
CGFloat const UPPER_MARGIN_BUBBLE_CTV = 1.5f;
CGFloat const BOTTOM_MARGIN_BUBBLE_CTV = 6.f;
CGFloat const NOTCH_MARGIN_BUBBLE_CTV = 6.f;
CGFloat const FLAT_MARGIN_BUBBLE_CTV = 6.f;

CGFloat const TOP_INSET_BUBBLE_CTV = 16.f;
CGFloat const LEFT_INSET_BUBBLE_CTV = 16.f;
CGFloat const BOTTOM_INSET_BUBBLE_CTV = 8.f;
CGFloat const RIGHT_INSET_BUBBLE_CTV = 8.f;

//Message view
CGFloat const UPPER_MARGIN_MESSAGE_VIEW_CTV = 10.f;
CGFloat const NOTCH_MARGIN_MESSAGE_VIEW_CTV = 18.f;
CGFloat const FLAT_MARGIN_MESSAGE_VIEW_CTV = 10.f;

//Sent mark
CGFloat const HEIGHT_SENT_MARK_CTV = 11;
CGFloat const WIDTH_SENT_MARK_CTV = 11;
CGFloat const RIGHT_MARGIN_SENT_MARK_CTV = 8;

CGFloat const FONT_SIZE_MESSAGE_VIEW_CTV = 17.f;

#pragma mark - Layout helpers

-(CGRect)_bubbleFrame{
    CGSize messageTextSize = [self _messageTextSize];
    return CGRectMake(NOTCH_MARGIN_BUBBLE_CTV, UPPER_MARGIN_BUBBLE_CTV, messageTextSize.width+ NOTCH_MARGIN_MESSAGE_VIEW_CTV + FLAT_MARGIN_MESSAGE_VIEW_CTV, messageTextSize.height+2*UPPER_MARGIN_MESSAGE_VIEW_CTV);
}

-(CGRect)_bubleFrameRight{
    CGSize messageTextFrame = [self _messageTextSize];
    return CGRectMake(self.bounds.size.width - messageTextFrame.width -NOTCH_MARGIN_MESSAGE_VIEW_CTV -FLAT_MARGIN_MESSAGE_VIEW_CTV -NOTCH_MARGIN_BUBBLE_CTV, UPPER_MARGIN_BUBBLE_CTV, messageTextFrame.width+NOTCH_MARGIN_MESSAGE_VIEW_CTV+FLAT_MARGIN_MESSAGE_VIEW_CTV, messageTextFrame.height + 2*UPPER_MARGIN_MESSAGE_VIEW_CTV + HEIGHT_SENT_MARK_CTV - 5);
}

-(CGRect)_messageViewFrame{
    CGSize messageTextSize = [self _messageTextSize];
    return CGRectMake(NOTCH_MARGIN_MESSAGE_VIEW_CTV, UPPER_MARGIN_MESSAGE_VIEW_CTV, messageTextSize.width, messageTextSize.height);
}

-(CGRect)_messageViewRightFrame{
    CGSize messageTextSize = [self _messageTextSize];
    return CGRectMake(self.bubble.bounds.size.width-(messageTextSize.width+NOTCH_MARGIN_MESSAGE_VIEW_CTV),UPPER_MARGIN_MESSAGE_VIEW_CTV, messageTextSize.width, messageTextSize.height);
}

-(CGSize)_messageTextSize{
    NSString* messageText =  self.messageView.text;
    return [messageText boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width*0.70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_MESSAGE_VIEW_CTV]} context:nil].size;
}

-(CGRect)_dateViewFrame{
    CGSize messageTextSize = [self _messageTextSize];
    return CGRectMake(messageTextSize.width + NOTCH_MARGIN_BUBBLE_CTV + FLAT_MARGIN_BUBBLE_CTV, 0 , self.contentView.bounds.size.width - messageTextSize.width - NOTCH_MARGIN_BUBBLE_CTV - FLAT_MARGIN_BUBBLE_CTV, messageTextSize.height + 2*UPPER_MARGIN_BUBBLE_CTV);
}

-(CGRect)_dateViewRightFrame{
    CGSize messageTextSize = [self _messageTextSize];
    return CGRectMake(0, 0 , self.contentView.bounds.size.width - messageTextSize.width - NOTCH_MARGIN_BUBBLE_CTV - FLAT_MARGIN_BUBBLE_CTV, messageTextSize.height + 2*UPPER_MARGIN_BUBBLE_CTV);
}

-(CGRect)_sentMarkRightFrame{
    CGRect textFrame = self.messageView.frame;
    return CGRectMake(self.bubble.bounds.size.width - WIDTH_SENT_MARK_CTV - 2*RIGHT_MARGIN_SENT_MARK_CTV, textFrame.origin.y + textFrame.size.height, WIDTH_SENT_MARK_CTV, HEIGHT_SENT_MARK_CTV);
}

+(CGFloat)heightForText:(Message*)message frame:(CGRect)frame{
    
    NSString* messageText =  message.message;
    
    CGFloat height = [messageText boundingRectWithSize:CGSizeMake(frame.size.width*0.70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_MESSAGE_VIEW_CTV]} context:nil].size.height;
    
    switch ((SNTypeMessage)[message.type integerValue]) {
        case SNReceiver:
            height += (2*UPPER_MARGIN_BUBBLE_CTV +2*UPPER_MARGIN_MESSAGE_VIEW_CTV);
            break;
        case SNSender:
            height += (HEIGHT_SENT_MARK_CTV + 2*UPPER_MARGIN_BUBBLE_CTV +2*UPPER_MARGIN_MESSAGE_VIEW_CTV );
            break;
    }
    
    return height;
}

#pragma mark - Custom accessors

-(void)setMessage:(Message *)message{
    _message = message;
    self.messageView.text = message.message;
    self.date.text = [self textForDate:message.date];
    switch ((SNTypeMessage)[self.message.type integerValue]) {
        case SNReceiver:
            self.bubble.image=[[UIImage imageNamed:@"chatBubbleLeftIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            self.messageView.textColor = [UIColor blackColor];
            self.sentMark.image = [UIImage new];
            break;
        case SNSender:
            self.bubble.image =[[UIImage imageNamed:@"chatBubbleRightIcon"]resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            self.messageView.textColor = [UIColor whiteColor];
            
            switch ((SNSendState)[self.message.sendState integerValue]) {
                case SNSendStateSending:
                    self.sentMark.image = [UIImage imageNamed:@"sendingIcon"];
                    break;
                case SNSendStateSent:
                    self.sentMark.image = [UIImage imageNamed:@"checkIcon"];
                    break;
                case SNSendStateFail:
                    self.sentMark.image = [UIImage imageNamed:@"sendMessageFailIcon"];
                    break;
                default:
                    break;
            }
            
            break;
    }
    
}

#pragma mark - Public

-(void)showMark{
    
}

#pragma mark - Override methods

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    BOOL oldValue = self.previousSelectedState;
    BOOL newValue = selected;

    if ((oldValue==YES && newValue==YES) || (oldValue== YES && newValue==NO)) {
        [self deselectCell];
        self.previousSelectedState = NO;
        return;
    }
    if (oldValue==NO && newValue==YES) {
        [self selectCell];
        self.previousSelectedState = YES;
        return;
    }
}

#pragma  mark - Helpers

-(void)selectCell{
    switch ((SNTypeMessage)[self.message.type integerValue]) {
        case SNReceiver:
            self.bubble.image=[[UIImage imageNamed:@"chatBubbleLeftSelectedIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            break;
        case SNSender:
            self.bubble.image =[[UIImage imageNamed:@"chatBubbleRightSelectedIcon"]resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            break;
    }
    self.date.alpha = 1.0;
    self.date.text = [self textForDate:self.message.date];
}

-(void)deselectCell{
    switch ((SNTypeMessage)[self.message.type integerValue]) {
        case SNReceiver:
            self.bubble.image=[[UIImage imageNamed:@"chatBubbleLeftIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            break;
        case SNSender:
            self.bubble.image =[[UIImage imageNamed:@"chatBubbleRightIcon"]resizableImageWithCapInsets:UIEdgeInsetsMake(TOP_INSET_BUBBLE_CTV, RIGHT_INSET_BUBBLE_CTV, BOTTOM_INSET_BUBBLE_CTV, LEFT_INSET_BUBBLE_CTV) resizingMode:UIImageResizingModeStretch];
            break;
    }
    self.date.alpha = 0.0;
    self.date.text = [self textForDate:self.message.date];
}

-(NSString*)textForDate:(NSDate*)date{
    double secondsInPost = [date timeIntervalSinceNow];
    if (secondsInPost<0) {
        secondsInPost = -1*secondsInPost;
        if (secondsInPost<60) {
            int seconds = secondsInPost;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.messages.selected-state.%d sec", @"{number of seconds} sec"),seconds];
        }else if(secondsInPost<3600){
            int minutes = secondsInPost/60;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.messages.selected-state.%d min", @"{number of minute} min"),minutes];
        }else if(secondsInPost<86400){
            int hours = secondsInPost/3600;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.messages.selected-state.%d h", @"{number of days} d"),hours];
        }else if (secondsInPost<604800){
            int days = secondsInPost/86400;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.messages.selected-state.%d d", @"{number of hours} h"),days];
        }else{
            int weeks = secondsInPost/604800;
            return [NSString stringWithFormat:NSLocalizedString(@"chat.messages.selected-state.%d w", @"{number of weeks} w"),weeks];
        }
    }else{
        return NSLocalizedString(@"app.general.At future", @"just for test");
    }
}

@end