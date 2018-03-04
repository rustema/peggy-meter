//
//  PDKInstance.m
//  PassiveDataKit
//
//  Created by Chris Karr on 5/4/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PassiveDataKit.h"

#import "PDKEventsGenerator.h"
#import "PDKLocationGenerator.h"
#import "PDKGooglePlacesGenerator.h"
#import "PDKAppleHealthKitGenerator.h"
#import "PDKPedometerGenerator.h"
#import "PDKBatteryGenerator.h"

#import "PDKDataReportViewController.h"

@interface PassiveDataKit ()

@property NSMutableDictionary * listeners;
@property NSMutableArray * transmitters;

@end

NSString * const PDKUserIdentifier = @"PDKUserIdentifier"; //!OCLINT
NSString * const PDKGenerator = @"PDKGenerator"; //!OCLINT
NSString * const PDKGeneratorIdentifier = @"PDKGeneratorIdentifier"; //!OCLINT
NSString * const PDKMixpanelToken = @"PDKMixpanelToken"; //!OCLINT
NSString * const PDKLastEventLogged = @"PDKLastEventLogged"; //!OCLINT
NSString * const PDKEventGenerator = @"PDKEventsGenerator"; //!OCLINT
NSString * const PDKMixpanelEventGenerator = @"PDKMixpanelEventGenerator"; //!OCLINT

NSString * const PDKGooglePlacesInstance = @"PDKGooglePlacesInstance"; //!OCLINT
NSString * const PDKGooglePlacesSpecificLocation = @"PDKGooglePlacesSpecificLocation"; //!OCLINT
NSString * const PDKGooglePlacesAPIKey = @"PDKGooglePlacesAPIKey"; //!OCLINT
NSString * const PDKGooglePlacesType = @"PDKGooglePlacesType"; //!OCLINT
NSString * const PDKGooglePlacesRadius = @"PDKGooglePlacesRadius"; //!OCLINT
NSString * const PDKGooglePlacesIncludeFullDetails = @"PDKGooglePlacesIncludeFullDetails"; //!OCLINT
NSString * const PDKGooglePlacesFreetextQuery = @"PDKGooglePlacesFreetextQuery"; //!OCLINT

@implementation PassiveDataKit

static PassiveDataKit * sharedObject = nil;

+ (PassiveDataKit *) sharedInstance
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
        self.listeners = [NSMutableDictionary dictionary];
        self.transmitters = [NSMutableArray array];
    }
    
    return self;
}

- (void) addTransmitter:(id<PDKTransmitter>) transmitter {
    if ([self.transmitters containsObject:transmitter] == NO) {
        [self.transmitters addObject:transmitter];
    }
}

- (BOOL) registerListener:(id<PDKDataListener>) listener forGenerator:(PDKDataGenerator) dataGenerator options:(NSDictionary *) options {
    NSString * key = [PassiveDataKit keyForGenerator:dataGenerator];
    
    NSMutableArray * dataListeners = [self.listeners valueForKey:key];
    
    if (dataListeners == nil) {
        dataListeners = [NSMutableArray array];
        
        [self.listeners setValue:dataListeners forKey:key];
        
        id<PDKGenerator> generator = [self generatorInstance:dataGenerator];
        [generator addListener:self options:options];
    }
    
    if ([dataListeners containsObject:listener] == NO) {
        [dataListeners addObject:listener];
    }

    [self.listeners setValue:dataListeners forKey:key];

    return YES;
}

- (BOOL) unregisterListener:(id<PDKDataListener>) listener forGenerator:(PDKDataGenerator) dataGenerator {
    NSString * key = [PassiveDataKit keyForGenerator:dataGenerator];

    NSMutableArray * dataListeners = [self.listeners valueForKey:key];
    
    if (dataListeners != nil) {
        [dataListeners removeObject:listener];
    
        [self.listeners setValue:dataListeners forKey:key];
    }
    
    return YES;
}

- (NSArray *) activeListeners {
    NSMutableArray * listeners = [NSMutableArray arrayWithArray:[self.listeners allKeys]];
    
    return listeners;
}

- (void) receivedData:(NSDictionary *) data forGenerator:(PDKDataGenerator) dataGenerator {
    NSString * key = [PassiveDataKit keyForGenerator:dataGenerator];
    NSString * anyKey = [PassiveDataKit keyForGenerator:PDKAnyGenerator];
    
    NSMutableArray * dataListeners = [NSMutableArray arrayWithArray:[self.listeners valueForKey:key]];
    
    [dataListeners addObjectsFromArray:[self.listeners valueForKey:anyKey]];

    for (id<PDKDataListener> listener in dataListeners) {
        [listener receivedData:data forGenerator:dataGenerator];
    }
}

- (void) receivedData:(NSDictionary *) data forCustomGenerator:(NSString *) generatorId {
    NSMutableArray * dataListeners = [NSMutableArray arrayWithArray:[self.listeners valueForKey:generatorId]];

    NSString * anyKey = [PassiveDataKit keyForGenerator:PDKAnyGenerator];
    [dataListeners addObjectsFromArray:[self.listeners valueForKey:anyKey]];

    for (id<PDKDataListener> listener in dataListeners) {
        [listener receivedData:data forCustomGenerator:generatorId];
    }
}

+ (NSString *) keyForGenerator:(PDKDataGenerator) generator
{
    switch(generator) { //!OCLINT
        case PDKLocation:
            return @"PDKLocationGenerator";
        case PDKGooglePlaces:
            return @"PDKGooglePlacesGenerator";
        case PDKEvents:
            return @"PDKEventsGenerator";
        case PDKAppleHealthKit:
            return @"PDKAppleHealthKit";
        case PDKPedometer:
            return @"PDKPedometer";
        case PDKBattery:
            return @"PDKBattery";
        case PDKAnyGenerator:
            return @"PDKAnyGenerator";
    }

    return @"PDKUnknownGenerator";
}

- (id<PDKGenerator>) generatorInstance:(PDKDataGenerator) generator {
    switch(generator) { //!OCLINT
        case PDKLocation:
            return [PDKLocationGenerator sharedInstance];
        case PDKGooglePlaces:
            return [PDKGooglePlacesGenerator sharedInstance];
        case PDKEvents:
            return [PDKEventsGenerator sharedInstance];
        case PDKAppleHealthKit:
            return [PDKAppleHealthKitGenerator sharedInstance];
        case PDKPedometer:
            return [PDKPedometerGenerator sharedInstance];
        case PDKBattery:
            return [PDKBatteryGenerator sharedInstance];
        case PDKAnyGenerator:
            break;
    }
    
    return nil;
}

- (void) logEvent:(NSString *) eventName properties:(NSDictionary *) properties {
    [[PDKEventsGenerator sharedInstance] logEvent:eventName properties:properties];
}

- (void) transmit:(BOOL) force {
    for (id<PDKTransmitter> transmitter in self.transmitters) {
        [transmitter transmit:force completionHandler:nil];
    }
}

- (void) transmitWithCompletionHandler:(void (^)(UIBackgroundFetchResult result)) completionHandler {
    for (id<PDKTransmitter> transmitter in self.transmitters) {
        [transmitter transmit:NO completionHandler:completionHandler];
    }
}

- (void) clearTransmitters {
    [self.transmitters removeAllObjects];
}

- (NSString *) identifierForUser {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * identifier = [defaults stringForKey:PDKUserIdentifier];
    
    if (identifier != nil) {
        return identifier;
    }
    
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (BOOL) setIdentifierForUser:(NSString *) newIdentifier {
    if (newIdentifier != nil) {
        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];

        [defaults setValue:newIdentifier forKey:PDKUserIdentifier];
        
        return YES;
    }
    
    return NO;
}

- (void) resetIdentifierForUser {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];

    [defaults removeObjectForKey:PDKUserIdentifier];
}

- (NSString *) userAgent {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];

    NSString * generator = [defaults stringForKey:PDKGenerator];
    
    if (generator != nil) {
        return generator;
    }
    
    NSMutableDictionary * info = [NSMutableDictionary dictionaryWithDictionary:[[NSBundle mainBundle] infoDictionary]];
    
    if (info[@"CFBundleName"] == nil) {
        info[@"CFBundleName"] = @"Passive Data Kit";
    }

    if (info[@"CFBundleShortVersionString"] == nil) {
        info[@"CFBundleShortVersionString"] = @"1.0";
    }
    
    return [NSString stringWithFormat:@"%@/%@", info[@"CFBundleName"], info[@"CFBundleShortVersionString"], nil];
}

- (UIViewController *) dataReportController {
    return [[PDKDataReportViewController alloc] init];
}

@end
