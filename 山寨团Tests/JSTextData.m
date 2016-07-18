//
//  JSTextData.m
//  山寨团
//
//  Created by jason on 15-1-28.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MetaDataTool.h"
@interface JSTextData : XCTestCase

@end

@implementation JSTextData

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
    XCTAssert(YES, @"Pass");
}



- (void)testLoadMetaData
{
    MetaDataTool *tool = [MetaDataTool shareMetaData];
    XCTAssert(tool.categories.count < 0,@"有问题");
}
@end
