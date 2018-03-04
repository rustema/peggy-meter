//
//  PDKPedometerSensor.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

@import Foundation;

#import "PDKBaseGenerator.h"

@interface PDKPedometerGenerator : PDKBaseGenerator

+ (PDKPedometerGenerator *) sharedInstance;

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options;

- (CGFloat) stepsBetweenStart:(NSTimeInterval) start end:(NSTimeInterval) end;

@end
