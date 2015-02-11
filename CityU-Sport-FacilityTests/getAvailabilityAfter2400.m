//
//  getAvailabilityAfter2400.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 11/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Connector.h"

@interface getAvailabilityAfter2400 : XCTestCase

@end

@implementation getAvailabilityAfter2400

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    Connector * connector = [[Connector alloc] initWithSessionId:@"1234567"];
    [connector requestCourts:@"1234" sid:@"" userType:@"" date:@"" facility:@"" success:^(NSDictionary * a, NSMutableDictionary * b, NSString * c) {
        XCTAssert(a);
    } error:^(NSString * m) {
        XCTAssert(m);
    } partHandler:^{
        XCTAssert(nil);
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
