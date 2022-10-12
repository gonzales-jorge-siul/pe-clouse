//
//  RKCLLocationValueTransformer.h
//  RestKit
//
//  Created by Blake Watters on 9/11/13.
//  Copyright (c) 2013 RestKit. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <RKValueTransformers/RKValueTransformers.h>

@interface RKCLLocationValueTransformer : RKValueTransformer

+ (instancetype)locationValueTransformerWithLatitudeKey:(NSString *)latitudeKey longitudeKey:(NSString *)longitudeKey;

@end
