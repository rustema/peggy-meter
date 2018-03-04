//
//  PDKBaseGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/18/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

@import Foundation;

#import "PassiveDataKit.h"

@interface PDKBaseGenerator : NSObject<PDKGenerator>

- (void) addListener:(id<PDKDataListener>) listener options:(NSDictionary *) options;
- (void) removeListener:(id<PDKDataListener>) listener;

@end
