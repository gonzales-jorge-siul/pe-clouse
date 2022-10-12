//
//  Message.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Message : NSManagedObject

typedef NS_ENUM(NSInteger, SNTypeMessage) {
    SNSender=1,
    SNReceiver=0
};

typedef NS_ENUM(NSInteger, SNSendState) {
    SNSendStateSending=0,
    SNSendStateSent=1,
    SNSendStateFail = 2
};

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSManagedObject *chat;
@property (nonatomic, retain) NSNumber * idMessage;
@property (nonatomic, retain) NSNumber * sendState;

@end
