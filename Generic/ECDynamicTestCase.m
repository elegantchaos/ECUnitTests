// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDynamicTestCase.h"

@implementation ECDynamicTestCase

@synthesize dynamicTestName;
@synthesize dynamicTestParameter;

+ (id)testCaseWithSelector:(SEL)selector param:(id)param
{
    ECDynamicTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    
    return tc;
}

+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name
{
    ECDynamicTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    tc.dynamicTestName = name;
    
    return tc;
}

- (NSString*)name
{
    NSString* result;
    
    if (self.dynamicTestName)
    {
        result = [NSString stringWithFormat:@"-[%@ %@%@]", NSStringFromClass([self class]), NSStringFromSelector(self.selector), self.dynamicTestName];
    }
    else 
    {
        result = [super name];
    }
    
    return result;
}

@end
