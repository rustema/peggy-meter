//
//  PDKAppleHealthKitGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

@import Foundation;

#import "PDKBaseGenerator.h"

extern NSString * const PDKAppleHealthKitRequestedTypes;

@interface PDKAppleHealthKitGenerator : PDKBaseGenerator

+ (PDKAppleHealthKitGenerator *) sharedInstance;

@end
