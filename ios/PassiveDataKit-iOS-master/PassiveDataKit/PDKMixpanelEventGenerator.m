//
//  PDKMixpanelEventGenerator.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/25/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PDKMixpanelEventGenerator.h"

@implementation PDKMixpanelEventGenerator

static PDKMixpanelEventGenerator * sharedObject = nil;

+ (PDKMixpanelEventGenerator *) sharedInstance
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

- (UIView *) visualizationForSize:(CGSize) size {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    return tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PDKMixpanelEventGeneratorCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PDKMixpanelEventGeneratorCell"];
    }
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKMixpanelEventGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];
    
    cell.textLabel.text = reviewPoints[indexPath.row][@"event"];
    cell.detailTextLabel.text = [reviewPoints[indexPath.row][@"recorded"] description];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKMixpanelEventGeneratorReviewPoints";
    
    NSArray * reviewPoints = [defaults valueForKey:key];

    return reviewPoints.count;
}

+ (void) logForReview:(NSDictionary *) payload {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSString * key = @"PDKMixpanelEventGeneratorReviewPoints";
    
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
    
    while (newPoints.count > 100) {
        [newPoints removeObjectAtIndex:(newPoints.count - 1)];
    }
    
    [defaults setValue:newPoints forKey:key];
    [defaults synchronize];
}

@end
