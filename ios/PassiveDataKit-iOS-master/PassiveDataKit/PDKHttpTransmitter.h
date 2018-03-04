//
//  PDKHttpTransmitter.h
//  PassiveDataKit
//
//  Created by Chris Karr on 6/18/17.
//  Copyright © 2017 Audacious Software. All rights reserved.
//

#import "PassiveDataKit.h"
#import "NSString+RAInflections.h"

#define PDK_SOURCE_KEY @"source"
#define PDK_TRANSMITTER_ID_KEY @"transmitter-id"
#define PDK_TRANSMITTER_UPLOAD_URL_KEY @"upload-url"
#define PDK_TRANSMITTER_REQUIRE_CHARGING_KEY @"require-charging"
#define PDK_TRANSMITTER_REQUIRE_WIFI_KEY @"require-wifi"

#define PDK_METADATA_KEY @"passive-data-metadata"
#define PDK_GENERATOR_ID_KEY @"generator-id"
#define PDK_GENERATOR_KEY @"generator"
#define PDK_TIMESTAMP_KEY @"timestamp"

#define PDK_DEFAULT_TRANSMITTER_ID @"http-transmitter"

@interface PDKHttpTransmitter : NSObject<PDKTransmitter, PDKDataListener>

@property NSString * source;
@property NSString * transmitterId;
@property NSURL * uploadUrl;
@property BOOL isTransmitting;

@end
