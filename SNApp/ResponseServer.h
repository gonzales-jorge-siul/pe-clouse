//
//  ResponseServer.h
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface ResponseServer : NSObject

@property(nonatomic,strong) NSString *response;
@property(nonatomic,strong) NSString *validationKey;
@property(nonatomic,strong) NSString *URLPhoto;

+(RKObjectMapping*)responseServerMapping;

@end
