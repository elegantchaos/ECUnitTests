//
//  ECUnitTestsTests.m
//  ECUnitTestsTests
//
//  Created by Sam Deane on 26/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ECParameterisedTestCase.h"

@interface ParameterisedTestsExample : ECParameterisedTestCase

@end

@implementation ParameterisedTestsExample

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)parameterisedTestExample
{
    STFail(@"Example test run with data item: %@", self.parameterisedTestDataItem);
}

@end
