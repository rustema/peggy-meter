//
//  PDKLocationGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 5/4/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import MapKit;

#import "PassiveDataKit.h"

#import "PDKBaseGenerator.h"

extern NSString *const PDKLocationAccuracyMode;
extern NSString *const PDKLocationAccuracyModeBest;
extern NSString *const PDKLocationAccuracyModeRandomized;
extern NSString *const PDKLocationAccuracyModeUserProvided;
extern NSString *const PDKLocationAccuracyModeDisabled;
extern NSString *const PDKLocationAccuracyModeUserProvidedDistance;
extern NSString *const PDKLocationAccuracyModeUserProvidedLatitude;
extern NSString *const PDKLocationAccuracyModeUserProvidedLongitude;


@interface PDKLocationGenerator : PDKBaseGenerator<CLLocationManagerDelegate, MKMapViewDelegate>

+ (PDKLocationGenerator *) sharedInstance;

- (CLLocation *) lastKnownLocation;
- (void) locationManager:(CLLocationManager *) manager didUpdateLocations:(NSArray<CLLocation *> *) locations;
- (void) refresh:(CLLocation *) location;

@end
