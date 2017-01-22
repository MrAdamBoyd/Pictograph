//
//  PictographUITests.m
//  PictographUITests
//
//  Created by Adam on 2015-09-30.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PictographUITests : XCTestCase

@end

@implementation PictographUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncodeWithEncEnabledAndNoPassword {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *encSwitch = app.switches[@"0"];
    [encSwitch tap];
    [app.buttons[@"Hide Message"] tap];
    [app.alerts[@"No Encryption Key"].collectionViews.buttons[@"Dismiss"] tap];
    
    [[[XCUIApplication alloc] init].switches[@"1"] tap];
}

- (void)testDecodeWithEncEnabledAndNoPassword {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *encSwitch = app.switches[@"0"];
    [encSwitch tap];
    [app.buttons[@"Show Message"] tap];
    [app.alerts[@"No Encryption Key"].collectionViews.buttons[@"Dismiss"] tap];
    
    [[[XCUIApplication alloc] init].switches[@"1"] tap];
}

@end
