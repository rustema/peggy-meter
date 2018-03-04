//
//  PDKBatteryGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 9/18/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

@import Foundation;

#import "PDKBaseGenerator.h"


@interface PDKBatteryGenerator : PDKBaseGenerator

+ (PDKBatteryGenerator *) sharedInstance;

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options;
- (void) refresh;

@end

