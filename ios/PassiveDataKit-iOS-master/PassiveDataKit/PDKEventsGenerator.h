//
//  PDKEventGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/25/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import UIKit;

#import "PassiveDataKit.h"

#import "PDKBaseGenerator.h"

@interface PDKEventsGenerator : PDKBaseGenerator<UITableViewDataSource, UITableViewDelegate>

extern NSString *const PDKEventsGeneratorEnabled;
extern NSString *const PDKEventsGeneratorCanDisable;

+ (PDKEventsGenerator *) sharedInstance;

- (void) logEvent:(NSString *) eventName properties:(NSDictionary *) properties;

@end
