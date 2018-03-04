//
//  PDKBatteryGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 9/18/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

#import "PDKBatteryGenerator.h"

NSString * const PDKBatteryLevel = @"level"; //!OCLINT

NSString * const PDKBatteryStatus = @"status"; //!OCLINT
NSString * const PDKBatteryStatusFull = @"full"; //!OCLINT
NSString * const PDKBatteryStatusCharging = @"charging"; //!OCLINT
NSString * const PDKBatteryStatusUnplugged = @"discharging"; //!OCLINT
NSString * const PDKBatteryStatusUnknown = @"unknown"; //!OCLINT

#define GENERATOR_ID @"pdk-device-battery"

@interface PDKBatteryGenerator()

@property NSMutableArray * listeners;
@property NSDictionary * lastOptions;

@end

static PDKBatteryGenerator * sharedObject = nil;

@implementation PDKBatteryGenerator

+ (PDKBatteryGenerator *) sharedInstance {
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super allocWithZone:nil] init];
        
    });
    
    return sharedObject;
}

+ (id) allocWithZone:(NSZone *) zone { //!OCLINT
    return [self sharedInstance];
}

- (id) init {
    if (self = [super init]) {
        self.listeners = [NSMutableArray array];
    }
    
    return self;
}

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options {
    if ([self.listeners containsObject:listener] == NO) {
        [self.listeners addObject:listener];
    }
    
    if (self.listeners.count > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:nil];

        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        [self batteryDidChange:nil];

    }
}

- (void) removeListener:(id<PDKDataListener>)listener {
    [self.listeners removeObject:listener];
    
    if (self.listeners.count == 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [UIDevice currentDevice].batteryMonitoringEnabled = NO;
    }
}

- (void) refresh {
    [self batteryDidChange:nil];
}


- (void) batteryDidChange:(NSNotification *) theNote {
    NSMutableDictionary * data = [NSMutableDictionary dictionary];

    float level = [UIDevice currentDevice].batteryLevel * 100.0;
    
    if (level < 0) {
        return;
    }
    
    data[PDKBatteryLevel] = [NSNumber numberWithFloat:level];
    
    switch([UIDevice currentDevice].batteryState) {
        case UIDeviceBatteryStateFull:
            data[PDKBatteryStatus] = PDKBatteryStatusFull;
            break;
        case UIDeviceBatteryStateCharging:
            data[PDKBatteryStatus] = PDKBatteryStatusCharging;
            break;
        case UIDeviceBatteryStateUnplugged:
            data[PDKBatteryStatus] = PDKBatteryStatusUnplugged;
            break;
        case UIDeviceBatteryStateUnknown:
            data[PDKBatteryStatus] = PDKBatteryStatusUnknown;
            break;
    }
    
    [[PassiveDataKit sharedInstance] receivedData:data forGenerator:PDKBattery];
}

- (NSString *) generatorId {
    return GENERATOR_ID;
}


@end
