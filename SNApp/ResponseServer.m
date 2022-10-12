//
//  ResponseServer.m
//  SNApp
//
//  Created by Force Close on 6/15/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "ResponseServer.h"

@implementation ResponseServer

+(NSDictionary *)elementToProperty{
    return @{@"response":@"response",
             @"validationKey":@"validationKey",
             @"photo":@"URLPhoto"};
}

+(RKObjectMapping *)responseServerMapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[ResponseServer class]];
    [mapping addAttributeMappingsFromDictionary:[ResponseServer elementToProperty]];
    return mapping;
}

@end
