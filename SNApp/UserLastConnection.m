//
//  UserLastConnection.m
//  SNApp
//
//  Created by Force Close on 8/26/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "UserLastConnection.h"

@implementation UserLastConnection

+(NSDictionary *)elementToProperty{
    return @{@"isConnect":@"connect",
             @"lastConnection":@"lastConnectionDate"};
}

+(RKObjectMapping *)userLastConnectionMapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[UserLastConnection class]];
    [mapping addAttributeMappingsFromDictionary:[UserLastConnection elementToProperty]];
    return mapping;
}

@end
