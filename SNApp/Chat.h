//
//  Chat.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Message;

@interface Chat : NSManagedObject

typedef NS_ENUM(NSInteger, SNStateChat) {
    SNBlock=2,
    SNPending=1,
    SNNormal=0
};

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * lastMessage;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) Account *interlocutor;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSString *interlocutorUsername;
@property (nonatomic, retain) NSNumber * isRead;

@end

@interface Chat (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
