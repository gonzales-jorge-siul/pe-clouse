//
//  SNLocationManager.m
//  SNApp
//
//  Created by Force Close on 6/18/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import "SNLocationManager.h"
#import "Preferences.h"

@interface SNLocationManager ()

@property (strong, nonatomic) CLLocationManager* manager;
@property (strong, nonatomic) NSMutableArray *observers;

@end

@implementation SNLocationManager

#pragma mark -  Life cycle

+(SNLocationManager *)sharedInstance{
    static SNLocationManager *sharedInstance =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate =self;
        _observers = [[NSMutableArray alloc] init];
        [self startLocationServices];
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                //Do nothing
                break;
            case kCLAuthorizationStatusNotDetermined:
                if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_manager requestWhenInUseAuthorization];
                }
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                break;
        }
    }
    return self;
}
#pragma mark - Custom accessors
-(CLLocation *)lastLocation{
    CLLocationCoordinate2D coordinate = [Preferences UserLastPosition];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    _lastLocation = location;
    return _lastLocation;
}

#pragma mark - Public
- (void) addLocationManagerDelegate:(id<SNLocationManagerDelegate>)delegate {
    if (![self.observers containsObject:delegate]) {
        [self.observers addObject:delegate];
    }
}

- (void) removeLocationManagerDelegate:(id<SNLocationManagerDelegate>)delegate {
    if ([self.observers containsObject:delegate]) {
        [self.observers removeObject:delegate];
    }
}

-(BOOL)AuthorizationStatusDeneid{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return NO;
        case kCLAuthorizationStatusNotDetermined:
            if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_manager requestWhenInUseAuthorization];
            }
            return NO;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return YES;
    }
}

-(CLLocation *)location{
    return [self.manager location];
}

-(void)stopLocationServices{
    [self performSelectorOnMainThread:@selector(stopLocationServicesOnMainThread) withObject:nil waitUntilDone:YES];
}

-(void)startLocationServices{
    [self performSelectorOnMainThread:@selector(startLocationServicesOnMainThread) withObject:nil waitUntilDone:YES];
}

#pragma mark - Private

-(void)startLocationServicesOnMainThread{
     if (nil == self.manager)
        self.manager = [[CLLocationManager alloc] init];
    
    self.manager.delegate = self;
    
    //1
    //[self.manager startMonitoringSignificantLocationChanges];
    
    //2
    self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.manager.distanceFilter = [[Preferences UserStepRadius] intValue];
    //self.manager.distanceFilter = 1;
    [self.manager startUpdatingLocation];
}

-(void)stopLocationServicesOnMainThread{
    [self.manager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate protocol

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* newLocation =[locations lastObject];
    if ([newLocation.timestamp timeIntervalSinceNow]< 15) {
        self.lastReportedLocation = newLocation;
        CLLocationDistance distance =  [newLocation distanceFromLocation:self.lastLocation];
        if (fabs(distance) >= ([[Preferences UserStepRadius] intValue]*1.1f)) {
            [Preferences setUserLastPosition:newLocation.coordinate];
            for(id<SNLocationManagerDelegate> observer in self.observers) {
                if (observer) {
                    [observer locationManagerDidUpdateLocation:[locations lastObject]];
                }
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
//            nothing to do
            break;
        case kCLAuthorizationStatusNotDetermined:
            if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_manager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            for(id<SNLocationManagerDelegate> observer in self.observers) {
                if (observer) {
                    [observer didDeniedAuthorizationStatus:status];
                }
            }
            break;
    }
}

@end
