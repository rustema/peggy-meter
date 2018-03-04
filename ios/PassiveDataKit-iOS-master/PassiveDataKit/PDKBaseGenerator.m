//
//  PDKBaseGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/18/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

#import "PDKBaseGenerator.h"

#define GENERATOR_ID @"pdk-base-generator"

@implementation PDKBaseGenerator

- (NSString *) fullGeneratorName {
    return [NSString stringWithFormat:@"%@: %@", [self generatorId], [[PassiveDataKit sharedInstance] userAgent]];
}

- (NSString *) generatorId {
    return GENERATOR_ID;
}

- (void) updateOptions:(NSDictionary *) options {
    NSLog(@"Implement %@ in subclass...", NSStringFromSelector(_cmd));
}

- (UIView *) visualizationForSize:(CGSize) size {
    NSLog(@"Implement %@ in subclass...", NSStringFromSelector(_cmd));

    return nil;
}

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options {
    NSLog(@"Implement %@ in subclass...", NSStringFromSelector(_cmd));
}

- (void) removeListener:(id<PDKDataListener>) listener {
    NSLog(@"Implement %@ in subclass...", NSStringFromSelector(_cmd));
}

@end
