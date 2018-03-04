//
//  PDKGooglePlacesGenerator.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/30/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PassiveDataKit.h"
#import "PDKBaseGenerator.h"

@interface PDKGooglePlacesGenerator : PDKBaseGenerator<PDKDataListener>

+ (PDKGooglePlacesGenerator *) sharedInstance;

@end
