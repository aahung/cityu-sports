//
//  getDateAfter2400.m
//  CityU-Sport-Facility
//
//  Created by Xinhong LIU on 11/2/15.
//  Copyright (c) 2015 ParseCool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Connector.h"

@interface getDateAfter2400 : XCTestCase

@end

@implementation getDateAfter2400

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
    [connector requestDates:@"1234" sid:@"1234" success:^(NSArray * a, NSString * b) {
        XCTAssert(a);
    } error:^(NSString *message) {
        XCTAssert(message);
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
