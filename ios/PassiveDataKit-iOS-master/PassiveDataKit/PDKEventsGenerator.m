//
//  PDKEventGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/25/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import UIKit;

#import "PassiveDataKit.h"

#import "PDKEventsGenerator.h"
#import "PDKEventsGeneratorViewController.h"

#define GENERATOR_ID @"pdk-app-event"

NSString * const PDKEventsGeneratorEnabled = @"PDKEventsGeneratorEnabled"; //!OCLINT
NSString * const PDKEventsGeneratorCanDisable = @"PDKEventsGeneratorCanDisable"; //!OCLINT

@implementation PDKEventsGenerator

static PDKEventsGenerator * sharedObject = nil;

+ (PDKEventsGenerator *) sharedInstance {
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedObject = [[super allocWithZone:nil] init];
        
    });
    
    return sharedObject;
}

+ (id) allocWithZone:(NSZone *) zone { //!OCLINT
    return [self sharedInstance];
}

- (UIView *) visualizationForSize:(CGSize) size {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    return tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PDKEventGeneratorCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PDKEventGeneratorCell"];
    }
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKEventGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];

    cell.textLabel.text = reviewPoints[indexPath.row][@"event"];
    cell.detailTextLabel.text = [reviewPoints[indexPath.row][@"recorded"] description];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKEventGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];

    return reviewPoints.count;
}

- (void) logEvent:(NSString *) eventName properties:(NSDictionary *) properties {
    NSMutableDictionary * event = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    NSDate * recorded = [NSDate date];
    
    event[@"event_name"] = eventName;
    event[@"event_details"] = properties;
    event[@"observed"] = @(1000 * recorded.timeIntervalSince1970);
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKEventGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];
    
    NSMutableArray * newPoints = [NSMutableArray array];
    
    if (reviewPoints != nil) {
        for (NSDictionary * point in reviewPoints) {
            if (point[@"recorded"] != nil) {
                [newPoints addObject:point];
            }
        }
    }
    
    [newPoints addObject:event];
    
    [newPoints sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2[@"recorded"] compare:obj1[@"recorded"]];
    }];
    
    while (newPoints.count > 100) {
        [newPoints removeObjectAtIndex:(newPoints.count - 1)];
    }
    
    [defaults setValue:newPoints forKey:key];
    // [defaults synchronize];
    
    [[PassiveDataKit sharedInstance] receivedData:event forGenerator:PDKEvents];
    
    NSLog(@"LOGGED EVENT: %@", eventName);
}

+ (UIViewController *) detailsController {
    return [[PDKEventsGeneratorViewController alloc] init];
}

- (NSString *) generatorId {
    return GENERATOR_ID;
}


@end
