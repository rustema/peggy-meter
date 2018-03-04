//
//  PassiveDataKitTests.m
//  PassiveDataKitTests
//
//  Created by Chris Karr on 5/4/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

@import Foundation;

#import <XCTest/XCTest.h>

#import "PassiveDataKit.h"

@interface PassiveDataKitTests : XCTestCase

@end

@implementation PassiveDataKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTest {
    XCTAssertTrue(YES, @"Testing is broken.");
}

- (void)testUpload {
/*
 PDKDataPointsManager * pdk = [PDKDataPointsManager sharedInstance];
    
    BOOL result = [pdk logDataPoint:@"PDK Tester" generatorId:@"pdk-tester" source:@"tester" properties:@{ @"foo": @"bar" }];
    
    XCTAssertTrue(result, @"Didn't log data point.");
    
    result = [pdk logEvent:@"test-event" properties:@{ @"hello": @"world" }];

    XCTAssertTrue(result, @"Didn't log data point.");

    result = [pdk logEvent:@"test-event-nil" properties:nil];
    
    XCTAssertTrue(result, @"Didn't log data point.");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Upload Complete"];

    [pdk uploadDataPoints:[NSURL URLWithString:@"https://pdk.audacious-software.com/data/add-bundle.json"] window:0 complete:^(BOOL success, int uploaded) {
        [expectation fulfill];

        XCTAssertTrue((uploaded > 0), @"Didn't upload data point.");
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
 */
}

- (void)testIdentifier {
/*
 PassiveDataKit * pdk = [PassiveDataKit sharedInstance];
    
    NSString * identifier = [pdk identifierForUser];
    
    XCTAssertNotNil(identifier);
    XCTAssertTrue(identifier.length == 36);
    
    NSString * originalIdentifier = identifier;
    
    XCTAssertTrue([pdk setIdentifierForUser:@"test@example.com"]);

    identifier = [pdk identifierForUser];

    XCTAssertNotNil(identifier);
    XCTAssertEqualObjects(identifier, @"test@example.com");
    
    [pdk resetIdentifierForUser];
    
    identifier = [pdk identifierForUser];
    
    XCTAssertNotNil(identifier);
    XCTAssertEqualObjects(identifier, originalIdentifier);
 */
}

- (void)testGenerator {
    /*
    PassiveDataKit * pdk = [PassiveDataKit sharedInstance];
    
    NSString * generator = [pdk generator];
    
    XCTAssertNotNil(generator);
    XCTAssertEqual([generator rangeOfString:@"Passive Data Kit 1.0"].location, 0);
    
    NSString * originalGenerator = generator;
    
    XCTAssertTrue([pdk setGenerator:@"PDK Test 1.2.3"]);
    
    generator = [pdk generator];
    
    XCTAssertNotNil(generator);
    XCTAssertEqualObjects(generator, @"PDK Test 1.2.3");
    
    [pdk resetGenerator];
    
    generator = [pdk generator];
    
    XCTAssertNotNil(generator);
    XCTAssertEqualObjects(generator, originalGenerator);
     */
}

- (void)testGeneratorId {
    /*
    PassiveDataKit * pdk = [PassiveDataKit sharedInstance];
    
    NSString * generatorId = [pdk generatorId];

    XCTAssertNotNil(generatorId);
    XCTAssertEqualObjects(generatorId, @"passive-data-kit");
    
    NSString * originalGeneratorId = generatorId;
    
    XCTAssertTrue([pdk setGeneratorId:@"pdk-test"]);
    
    generatorId = [pdk generatorId];
    
    XCTAssertNotNil(generatorId);
    XCTAssertEqualObjects(generatorId, @"pdk-test");
    
    [pdk resetGeneratorId];
    
    generatorId = [pdk generatorId];
    
    XCTAssertNotNil(generatorId);
    XCTAssertEqualObjects(generatorId, originalGeneratorId);
     */
}


@end
