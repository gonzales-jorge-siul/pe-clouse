//
//  SNLocationManager.h
//  SNApp
//
//  Created by Force Close on 6/18/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol SNLocationManagerDelegate <NSObject>

-(void)locationManagerDidUpdateLocation:(CLLocation *)location;
-(void)didDeniedAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@interface SNLocationManager : NSObject<CLLocationManagerDelegate>

+(SNLocationManager *)sharedInstance;

@property (strong, nonatomic) CLLocation* lastLocation;
@property (strong, nonatomic) CLLocation* lastReportedLocation;

-(CLLocation*)location;
-(BOOL)AuthorizationStatusDeneid;
-(void)addLocationManagerDelegate:(id<SNLocationManagerDelegate>) delegate;
-(void)removeLocationManagerDelegate:(id<SNLocationManagerDelegate>) delegate;

-(void)stopLocationServices;
-(void)startLocationServices;

@end
