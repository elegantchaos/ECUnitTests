// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

// --------------------------------------------------------------------------
//! This subclass has some extra support to help with
//! constructing dynamic test suites at runtime.
//! 
//! This is handy when you've got a test or tests that you want
//! to run multiple times with different parameters.
// --------------------------------------------------------------------------

@interface ECDynamicTestCase : ECTestCase
{
@private
	id dynamicTestParameter;
	NSString* dynamicTestName;
}

@property (strong, nonatomic) id dynamicTestParameter;
@property (strong, nonatomic) NSString* dynamicTestName;

+ (id)testCaseWithSelector:(SEL)selector param:(id)param;
+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name;

@end
