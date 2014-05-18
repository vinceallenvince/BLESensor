//
//  XYZMainViewControllerTestCase.m
//  BLESensor
//
//  Created by Vince Allen on 5/18/14.
//  Copyright (c) 2014 Vince Allen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XYZMainViewController.h"

@interface XYZMainViewControllerTestCase : XCTestCase

@end

@implementation XYZMainViewControllerTestCase

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

- (void)testPackageData
{
    NSString *myRoll = @"-0.892";
    UInt8 type = 0x41;
    
    XYZMainViewController *controller = [[XYZMainViewController alloc] init];
    NSData *data = [controller packageDataAsType:type FromString:myRoll];
    
    UInt8 buf[1];
    [data getBytes:buf length:1];
    XCTAssertEqual([data length], 9, @"Should have 9 entries.");
}

@end
