//
//  PDKLocationAnnotation.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PDKLocationAnnotation.h"

@interface PDKLocationAnnotation()

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property NSDate * date;

@end

@implementation PDKLocationAnnotation

- (id) initWithLocation:(CLLocation *) location forDate:(NSDate *) date {
    if (self = [super init]) {
        self.coordinate = location.coordinate;
        self.date = date;
    }
    
    return self;
}

- (NSString *) title {
    return [self.date description];
}

@end
