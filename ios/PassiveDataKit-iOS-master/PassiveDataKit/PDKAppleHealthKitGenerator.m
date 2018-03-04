//
//  PDKAppleHealthKitGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/26/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

#import "PDKAppleHealthKitGenerator.h"

NSString * const PDKAppleHealthKitRequestedTypes = @"PDKAppleHealthKitRequestedTypes"; //!OCLINT

@interface PDKAppleHealthKitGenerator ()

@property NSMutableArray * listeners;
@property NSDictionary * lastOptions;

@property (nonatomic, copy) void (^accessDeniedBlock)(void);

@end

static PDKAppleHealthKitGenerator * sharedObject = nil;

@implementation PDKAppleHealthKitGenerator

+ (PDKAppleHealthKitGenerator *) sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super allocWithZone:nil] init];
        
    });
    
    return sharedObject;
}

+ (id) allocWithZone:(NSZone *) zone //!OCLINT
{
    return [self sharedInstance];
}

- (id) init
{
    if (self = [super init])
    {
        self.listeners = [NSMutableArray array];

    }
    
    return self;
}

@end
