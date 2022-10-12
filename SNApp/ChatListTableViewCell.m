//
//  ChatListTableViewCell.m
//  SNApp
//
//  Created by JG on 7/8/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ChatListTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "Account.h"

@interface ChatListTableViewCell ()
@property(nonatomic,strong)UIImageView* photo;
@property(nonatomic,strong)UILabel* name;
@property(nonatomic,strong)UILabel* lastMessage;
@property(nonatomic,strong)UILabel* lastMessageDate;
@end

@implementation ChatListTableViewCell
#pragma mark - Life cycle
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
        _photo = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photo.layer.cornerRadius = 4.f;
        _photo.clipsToBounds = YES;
        [self.contentView addSubview:_photo];
        
        _name = [[UILabel alloc] initWithFrame:CGRectZero];
        _name.font = [UIFont boldSystemFontOfSize:FONT_SIZE_NAME_CL];
        _name.textColor = [UIColor blackColor];
        _name.numberOfLines = 1;
        _name.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_name];
        
        _lastMessage = [[UILabel alloc] initWithFrame:CGRectZero];
        _lastMessage.font = [UIFont systemFontOfSize:FONT_SIZE_LAST_MESSAGE_CL];
        _lastMessage.textColor = [UIColor blackColor];
        _lastMessage.numberOfLines = 1 ;
        _lastMessage.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lastMessage];
        
        _lastMessageDate = [[UILabel alloc] initWithFrame:CGRectZero];
        _lastMessageDate.font = [UIFont systemFontOfSize:12.0];
        _lastMessageDate.textColor = [UIColor blackColor];
        _lastMessageDate.numberOfLines = 1;
        _lastMessageDate.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_lastMessageDate];
        
        [self.contentView bringSubviewToFront:_name];
        
        self.contentView.clipsToBounds =YES;
        self.clipsToBounds =YES;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.photo setFrame:[self _photoFrame]];
    [self.name setFrame:[self _nameFrame]];
    [self.lastMessage setFrame:[self _lastMessageFrame]];
    [self.lastMessageDate setFrame:[self _lastMessageDateFrame]];
}

#pragma mark - Constants
//Photo
CGFloat const HEIGHT_PHOTO_CL=60.0;
CGFloat const LEFT_MARGIN_PHOTO_CL=12.0;
CGFloat const UPPPER_MARGIN_PHOTO_CL=12.0;
//Name
CGFloat const LEFT_MARGIN_NAME_CL=0.f;
CGFloat const RIGHT_MARGIN_NAME_CL=15.0;
CGFloat const UPPER_MARGIN_NAME_CL=0.f;
CGFloat const FONT_SIZE_NAME_CL = 17.0;
//Last message
CGFloat const LEFT_MARGIN_LAST_MESSAGE_CL=6.0;
CGFloat const RIGHT_MARGIN_LAST_MESSAGE_CL=12.0;
CGFloat const UPPER_MARGIN_LAST_MESSAGE_CL=0.f;
CGFloat const FONT_SIZE_LAST_MESSAGE_CL = 15.0;
//Last message date
CGFloat const RIGHT_MARGIN_LAST_MESSAGE_DATE_CL = 6.0;
CGFloat const UPPER_MARGIN_LAST_MESSAGE_DATE_CL = 2.f;
//Content view
CGFloat const BOTTON_MARGIN_CONTENT_VIEW_CL =6.0;
#pragma mark - Layout helpers

-(CGRect)_photoFrame{
    CGFloat containterSize = self.bounds.size.height;
    CGFloat margin = (containterSize - HEIGHT_PHOTO_CL)/2.f;
    return CGRectMake(margin,margin , HEIGHT_PHOTO_CL, HEIGHT_PHOTO_CL);
}
-(CGRect)_nameFrame{
    CGSize nameTextSize = [self _nameTextSize];
    CGRect photoSize = self.photo.frame;
    CGFloat upperMargin = self.bounds.size.height/2.f - nameTextSize.height - UPPER_MARGIN_NAME_CL;
    CGFloat leftMargin  =2*photoSize.origin.x + photoSize.size.width + LEFT_MARGIN_NAME_CL;
    return CGRectMake(leftMargin, upperMargin, nameTextSize.width, nameTextSize.height);
}
-(CGSize)_nameTextSize{
    NSString* nameText = self.name.text;
    CGSize textDateSize = [self.lastMessageDate.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :  self.lastMessageDate.font} context:nil].size;
    return [nameText boundingRectWithSize:CGSizeMake(self.bounds.size.width- 2*self.photo.frame.origin.x - self.photo.frame.size.width - LEFT_MARGIN_NAME_CL -RIGHT_MARGIN_NAME_CL - textDateSize.width ,self.name.font.lineHeight*1.2) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE_NAME_CL]} context:nil].size;
}
-(CGRect)_lastMessageFrame{
    CGRect photoSize = self.photo.frame;
    CGFloat upperMargin = self.bounds.size.height/2.f + UPPER_MARGIN_LAST_MESSAGE_CL;
    CGFloat leftMargin = 2*photoSize.origin.x + photoSize.size.width + LEFT_MARGIN_LAST_MESSAGE_CL;
    return CGRectMake(leftMargin, upperMargin, self.contentView.bounds.size.width -leftMargin-RIGHT_MARGIN_LAST_MESSAGE_CL, self.lastMessage.font.lineHeight);
}
-(CGRect)_lastMessageDateFrame{
    CGSize textSize = [self.lastMessageDate.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName :  self.lastMessageDate.font} context:nil].size;
    CGFloat upperMargin = self.bounds.size.height/2.f - textSize.height - UPPER_MARGIN_LAST_MESSAGE_DATE_CL;
    return CGRectMake(self.contentView.bounds.size.width - textSize.width - RIGHT_MARGIN_LAST_MESSAGE_DATE_CL,upperMargin, textSize.width, textSize.height);
    
//    return CGRectMake(0, self.name.frame.origin.y, self.contentView.bounds.size.width - RIGHT_MARGIN_LAST_MESSAGE_DATE_CL , self.lastMessageDate.font.lineHeight);
}

#pragma mark - Custom accesors
-(void)setChat:(Chat *)chat{
    _chat = chat;
    if ([self.chat.interlocutor.photo isEqualToString:@""]) {
        [self.photo setImage:[UIImage imageNamed:@"emptyPhotoUserIcon"]];
    }else{
        [self.photo setImageWithURL:[NSURL URLWithString:self.chat.interlocutor.photo] placeholderImage:[UIImage imageNamed:@"whiteBackground"]];
    }
    self.name.text = self.chat.interlocutor.name;
    self.lastMessage.text = self.chat.lastMessage;
    self.lastMessageDate.text = [self textForDate:self.chat.date];
    if (![self.chat.isRead boolValue]) {
//        self.name.font = [UIFont boldSystemFontOfSize:FONT_SIZE_NAME_CL];
        self.lastMessage.font = [UIFont boldSystemFontOfSize:FONT_SIZE_LAST_MESSAGE_CL];
    }else{
//        self.name.font = [UIFont systemFontOfSize:FONT_SIZE_NAME_CL];
        self.lastMessage.font = [UIFont systemFontOfSize:FONT_SIZE_LAST_MESSAGE_CL];
    }
}

-(NSString*)textForDate:(NSDate*)date{
    double secondsInPost = [date timeIntervalSinceNow];
   // secondsInPost -=14400;
    if (secondsInPost<0) {
        secondsInPost = -1*secondsInPost;
        if (secondsInPost<60) {
            int seconds = secondsInPost;
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.%d s", @"{number of seconds} s"),seconds];
        }else if(secondsInPost<3600){
            int minutes = secondsInPost/60;
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.%d m", @"{number of minutes} m"),minutes];
        }else if(secondsInPost<86400){
            int hours = secondsInPost/3600;
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.%d h", @"{number of hours} h"),hours];
        }else if (secondsInPost<604800){
            int days = secondsInPost/86400;
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.%d d", @"{number of days} d"),days];
        }else{
            int weeks = secondsInPost/604800;
            return [NSString stringWithFormat:NSLocalizedString(@"chatlist.chat.%d w", @"{number of weeks} w"),weeks];
        }
    }else{
        return NSLocalizedString(@"app.general.At future", @"just for test");
    }
}

//+(CGFloat)heigthForName:(NSString*)name lastMessage:(NSString*)lastMessage contentWidth:(CGFloat)width{
//    NSString* nameText = name;
//    CGSize nameTextSize= [nameText boundingRectWithSize:CGSizeMake(width-LEFT_MARGIN_PHOTO_CL-HEIGHT_PHOTO_CL-LEFT_MARGIN_NAME_CL*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_NAME_CL]} context:nil].size;
//    NSString* lastMessageText = lastMessage;
//    CGSize lastMessageTextSize = [lastMessageText boundingRectWithSize:CGSizeMake(width-LEFT_MARGIN_PHOTO_CL-HEIGHT_PHOTO_CL-LEFT_MARGIN_LAST_MESSAGE_CL*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_LAST_MESSAGE_CL]} context:nil].size;
//    CGRect lastMessageFrame=CGRectMake(LEFT_MARGIN_PHOTO_CL+HEIGHT_PHOTO_CL +LEFT_MARGIN_LAST_MESSAGE_CL, UPPER_MARGIN_NAME_CL+nameTextSize.height+UPPER_MARGIN_LAST_MESSAGE_CL, lastMessageTextSize.width, lastMessageTextSize.height);
//    return MAX(UPPPER_MARGIN_PHOTO_CL+HEIGHT_PHOTO_CL+BOTTON_MARGIN_CONTENT_VIEW_CL,lastMessageFrame.origin.y + lastMessageFrame.size.height +BOTTON_MARGIN_CONTENT_VIEW_CL );
//}

@end
