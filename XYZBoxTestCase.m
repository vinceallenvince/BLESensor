//
//  XYZBoxTestCase.m
//  BLESensor
//
//  Created by Vince Allen on 5/18/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XYZBox.h"

@interface XYZBoxTestCase : XCTestCase

@end

@implementation XYZBoxTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReturnsSumOfTwoNumbers
{
    XYZBox *box = [[XYZBox alloc] init];
    int sum = [box addX:1 ToY:3];
    XCTAssertEqual(sum, 4, @"Should have added to numbers.");
}

@end
