//
//  SNServer.m
//  SNApp
//
//  Created by Force Close on 10/31/15.
//  Copyright © 2015 Force Close. All rights reserved.
//

#import "SNServer.h"

@implementation SNServer

+(NSDictionary *)elementToProperty{
    return @{@"response":@"date"};
}

+(RKObjectMapping *)serverMapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[SNServer class]];
    [mapping addAttributeMappingsFromDictionary:[SNServer elementToProperty]];
    return mapping;
}

@end
