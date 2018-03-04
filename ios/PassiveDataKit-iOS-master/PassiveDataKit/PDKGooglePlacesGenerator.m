//
//  PDKGooglePlacesGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/30/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import CoreLocation;

#import "PDKAFNetworkReachabilityManager.h"
#import "PDKAFHTTPSessionManager.h"

#import "PDKGooglePlacesGenerator.h"
#import "PDKLocationGenerator.h"

@interface PDKGooglePlacesGenerator ()

@property PDKAFNetworkReachabilityManager * reach;

@property NSMutableArray * listeners;
@property NSDictionary * lastOptions;

@end

@implementation PDKGooglePlacesGenerator

static PDKGooglePlacesGenerator * sharedObject = nil;

+ (PDKGooglePlacesGenerator *) sharedInstance
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

- (id) init {
    if (self = [super init]) {
        self.listeners = [NSMutableArray array];
    }
    
    return self;
}

- (void) removeListener:(id<PDKDataListener>)listener {
    [self.listeners removeObject:listener];
    
    if (self.listeners.count == 0) { //!OCLINT
        // Shut down sensors...
    }
}

- (void) updateOptions:(NSDictionary *) options {
    if (options == nil) {
        options = @{}; //!OCLINT
    }
    
    NSArray * existingListeners = [NSArray arrayWithArray:self.listeners];
    
    for (id<PDKDataListener> listener in existingListeners) {
        [self removeListener:listener];
    }
    
    for (id<PDKDataListener> listener in existingListeners) {
        [self addListener:listener options:options];
    }
}

- (void) addListener:(id<PDKDataListener>)listener options:(NSDictionary *) options {
    if (options == nil) {
        options = @{}; //!OCLINT
    }
    
    self.lastOptions = options;

    if (listener != nil) {
        [self.listeners addObject:listener];
    }

    if (self.lastOptions[PDKGooglePlacesSpecificLocation] != nil) {
        CLLocation * location = self.lastOptions[PDKGooglePlacesSpecificLocation];
        
        [self transmitPlacesForLocation:location];
    } else if (self.lastOptions[PDKGooglePlacesFreetextQuery] != nil) {
        [self transmitPlacesForFreetextQuery:self.lastOptions[PDKGooglePlacesFreetextQuery]];
    } else {
        if (self.listeners.count == 1) {
            [[PassiveDataKit sharedInstance] registerListener:self forGenerator:PDKLocation options:options];
            
            [[PDKLocationGenerator sharedInstance] updateOptions:options];
        }
    }
}

- (NSURL *) urlForLocation:(CLLocation *) location {
    NSMutableString * urlString = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"];
    
    [urlString appendFormat:@"key=%@&", self.lastOptions[PDKGooglePlacesAPIKey]];
    [urlString appendFormat:@"location=%f,%f&", location.coordinate.latitude, location.coordinate.longitude];
    
    if (self.lastOptions[PDKGooglePlacesType] == nil) {
        CGFloat radius = 500;
        
        if (self.lastOptions[PDKGooglePlacesRadius] != nil) {
            radius = [self.lastOptions[PDKGooglePlacesRadius] doubleValue];
        }
        
        [urlString appendFormat:@"radius=%f", radius];
    } else {
        [urlString appendFormat:@"type=%@&", self.lastOptions[PDKGooglePlacesType]];
        [urlString appendString:@"rankby=distance"];
    }
    
    return [NSURL URLWithString:urlString];
}

- (NSURL *) urlForFreetextQuery:(NSString *) query {
    NSMutableString * urlString = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/place/textsearch/json?"];
    
    [urlString appendFormat:@"key=%@&", self.lastOptions[PDKGooglePlacesAPIKey]];
    
    NSMutableCharacterSet * charSet = [[NSMutableCharacterSet alloc] init];
    [charSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [charSet removeCharactersInString:@"?&="];
    
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
    [urlString appendFormat:@"query=%@&", query];
    
    if (self.lastOptions[PDKGooglePlacesType] != nil) {
        [urlString appendFormat:@"type=%@&", self.lastOptions[PDKGooglePlacesType]];
    }

    return [NSURL URLWithString:urlString];
}

- (NSURL *) urlForPlaceId:(NSString *) placeId {
    NSMutableString * urlString = [NSMutableString stringWithString:@"https://maps.googleapis.com/maps/api/place/details/json?"];
    
    [urlString appendFormat:@"key=%@&", self.lastOptions[PDKGooglePlacesAPIKey]];
    [urlString appendFormat:@"placeid=%@", placeId];
    
    return [NSURL URLWithString:urlString];
}

+ (void) logForReview:(NSDictionary *) payload {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKGooglePlacesGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];
    
    NSMutableArray * newPoints = [NSMutableArray array];
    
    if (reviewPoints != nil) {
        for (NSDictionary * point in reviewPoints) {
            if (point[@"recorded"] != nil) {
                [newPoints addObject:point];
            }
        }
    }
    
    NSMutableDictionary * reviewPoint = [NSMutableDictionary dictionaryWithDictionary:payload];
    [reviewPoint setValue:[NSDate date] forKey:@"recorded"];
    
    [newPoints addObject:reviewPoint];
    
    [newPoints sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2[@"recorded"] compare:obj1[@"recorded"]];
    }];
    
    while (newPoints.count > 50) {
        [newPoints removeObjectAtIndex:(newPoints.count - 1)];
    }
    
    [defaults setValue:newPoints forKey:key];
    [defaults synchronize];
}

- (void) transmitPlacesForLocation:(CLLocation *) location {
    self.reach = [PDKAFNetworkReachabilityManager managerForDomain:@"maps.googleapis.com"];
    
    __unsafe_unretained PDKGooglePlacesGenerator * weakSelf = self;
    
    [self.reach setReachabilityStatusChangeBlock:^(PDKAFNetworkReachabilityStatus status){
        if (status == PDKAFNetworkReachabilityStatusReachableViaWWAN || status == PDKAFNetworkReachabilityStatusReachableViaWiFi)
        {
            PDKAFHTTPSessionManager *manager = [PDKAFHTTPSessionManager manager];

            manager.responseSerializer = [PDKAFHTTPResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
            
            [manager GET:[weakSelf urlForLocation:location].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {

                NSError * error = nil;

                NSDictionary * response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];

                NSMutableDictionary * log = [NSMutableDictionary dictionary];
                [log setValue:[NSDate date] forKey:@"recorded"];
                [log setValue:response[@"results"] forKey:@"response"];
            
                [PDKGooglePlacesGenerator logForReview:log];
                
                NSMutableDictionary * data = [NSMutableDictionary dictionary];
                
                [data setValue:response[@"results"] forKey:PDKGooglePlacesInstance];
                
                if (self.lastOptions[PDKGooglePlacesIncludeFullDetails] != nil && [self.lastOptions[PDKGooglePlacesIncludeFullDetails] boolValue]) {
                    for (NSDictionary * place in response[@"results"]) {
                        NSData * placeData = [[NSData alloc] initWithContentsOfURL:[weakSelf urlForPlaceId:place[@"place_id"]]];
                        
                        NSDictionary * placeResponse = [NSJSONSerialization JSONObjectWithData:placeData options:0 error:&error];
                            
                        [data setValue:placeResponse[@"result"] forKey:place[@"place_id"]];
                    }
                }
                for (id<PDKDataListener> listener in weakSelf.listeners) {
                    [listener receivedData:data forGenerator:PDKGooglePlaces];
                }
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                // TODO: Log failure...
            }];
        }
        
        [weakSelf.reach stopMonitoring];
        weakSelf.reach = nil;
    }];
    
    [self.reach startMonitoring];
}

- (void) transmitPlacesForFreetextQuery:(NSString *) query {
    self.reach = [PDKAFNetworkReachabilityManager managerForDomain:@"maps.googleapis.com"];
    
    __unsafe_unretained PDKGooglePlacesGenerator * weakSelf = self;
    
    [self.reach setReachabilityStatusChangeBlock:^(PDKAFNetworkReachabilityStatus status){
        if (status == PDKAFNetworkReachabilityStatusReachableViaWWAN || status == PDKAFNetworkReachabilityStatusReachableViaWiFi)
        {
            PDKAFHTTPSessionManager *manager = [PDKAFHTTPSessionManager manager];
            
            manager.responseSerializer = [PDKAFHTTPResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
            
            [manager GET:[weakSelf urlForFreetextQuery:query].absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                
                NSError * error = nil;
                
                NSDictionary * response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];

                NSMutableDictionary * log = [NSMutableDictionary dictionary];
                [log setValue:[NSDate date] forKey:@"recorded"];
                [log setValue:response[@"results"] forKey:@"response"];
                
                [PDKGooglePlacesGenerator logForReview:log];
                
                NSMutableDictionary * data = [NSMutableDictionary dictionary];
                
                [data setValue:response[@"results"] forKey:PDKGooglePlacesInstance];
                
                if (self.lastOptions[PDKGooglePlacesIncludeFullDetails] != nil && [self.lastOptions[PDKGooglePlacesIncludeFullDetails] boolValue]) {
                    for (NSDictionary * place in response[@"results"]) {
                        NSData * placeData = [[NSData alloc] initWithContentsOfURL:[weakSelf urlForPlaceId:place[@"place_id"]]];
                        
                        NSDictionary * placeResponse = [NSJSONSerialization JSONObjectWithData:placeData options:0 error:&error];
                        
                        [data setValue:placeResponse[@"result"] forKey:place[@"place_id"]];
                    }
                }
                
                for (id<PDKDataListener> listener in weakSelf.listeners) {
                    [listener receivedData:data forGenerator:PDKGooglePlaces];
                }
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"ERROR: %@", error);
                // TODO: Log failure...
            }];
        }
        
        [weakSelf.reach stopMonitoring];
        weakSelf.reach = nil;
    }];
    
    [self.reach startMonitoring];
}



- (void) receivedData:(NSDictionary *) data forGenerator:(PDKDataGenerator) dataGenerator {
    [self transmitPlacesForLocation:[data valueForKey:PDKLocationInstance]];
}

- (void) receivedData:(NSDictionary *) data forCustomGenerator:(NSString *) generatorId {
    NSLog(@"Warning: Does not use non-standard location generator...");
}

- (UIView *) visualizationForSize:(CGSize) size {
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    view.backgroundColor = [UIColor redColor];
    
    return view;
}

@end
