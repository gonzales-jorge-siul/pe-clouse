//
//  UserLastConnection.h
//  SNApp
//
//  Created by Force Close on 8/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface UserLastConnection : NSObject

@property(nonatomic,strong,getter=isConnect)NSNumber* connect;
@property(nonatomic,strong)NSDate* lastConnectionDate;

+(RKObjectMapping*)userLastConnectionMapping;

@end
