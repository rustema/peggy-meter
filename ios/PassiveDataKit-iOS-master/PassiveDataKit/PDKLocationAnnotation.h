//
//  PDKLocationAnnotation.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import MapKit;

@interface PDKLocationAnnotation : NSObject<MKAnnotation>

- (id) initWithLocation:(CLLocation *) location forDate:(NSDate *) date;

@end
