// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDynamicTestCase.h"

#import <objc/runtime.h>

@implementation ECDynamicTestCase

@synthesize dynamicTestName;
@synthesize dynamicTestParameter;

// --------------------------------------------------------------------------
//! Make a test case with a given selector and parameter.
// --------------------------------------------------------------------------

+ (id)testCaseWithSelector:(SEL)selector param:(id)param
{
    ECDynamicTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    
    return tc;
}

// --------------------------------------------------------------------------
//! Make a test case with a given selector, parameter and a custom name.
// --------------------------------------------------------------------------

+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name
{
    ECDynamicTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    tc.dynamicTestName = name;
    
    return tc;
}

// --------------------------------------------------------------------------
//! Return the test case's name.
//! If we've overridden the default method name, we return
//! that, otherwise we do the default thing.
// --------------------------------------------------------------------------

- (NSString*)name
{
    NSString* result;
    
    if (self.dynamicTestName)
    {
        result = [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass([self class]), self.dynamicTestName];
    }
    else 
    {
        result = [super name];
    }
    
    return result;
}


#pragma mark - Tests

// --------------------------------------------------------------------------
//! Return a dictionary of test data.
//! By default, we try to load a plist from the test bundle
//! that has the same name as this class, and return that.
// --------------------------------------------------------------------------

+ (NSDictionary*) dynamicTestData
{
    NSURL* plist = [[NSBundle bundleForClass:[self class]] URLForResource:NSStringFromClass([self class]) withExtension:@"plist"];
    NSDictionary* result = [NSDictionary dictionaryWithContentsOfURL:plist];
    
    return result;
}

// --------------------------------------------------------------------------
//! Return the tests.
//! We iterate through our instance methods looking for ones
//! that begin with "dynamicTest".
//! For each one that we find, we add a sub-suite of tests applying
//! each item of test data in turn.
// --------------------------------------------------------------------------

+ (id) defaultTestSuite
{
    SenTestSuite* result = nil;
    NSDictionary* data = [self dynamicTestData];
    if (data)
    {
        result = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];
        unsigned int methodCount;
        Method* methods = class_copyMethodList([self class], &methodCount);
        for (NSUInteger n = 0; n < methodCount; ++n)
        {
            SEL selector = method_getName(methods[n]);
            NSString* name = NSStringFromSelector(selector);
            if ([name rangeOfString:@"dynamicTest"].location == 0)
            {
                SenTestSuite* subSuite = [[SenTestSuite alloc] initWithName:name];
                for (NSString* testName in data)
                {
                    NSDictionary* testData = [data objectForKey:testName];
                    [subSuite addTest:[self testCaseWithSelector:selector param:testData name:testName]];
                }
                [result addTest:subSuite];
                [subSuite release];
            }
        }
        
    }

    return [result autorelease];
}

@end
