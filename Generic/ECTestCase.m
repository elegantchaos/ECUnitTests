// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

@implementation ECTestCase

@synthesize dynamicTestName;
@synthesize dynamicTestParameter;

+ (id)testCaseWithSelector:(SEL)selector param:(id)param
{
    ECTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    
    return tc;
}

+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name
{
    ECTestCase* tc = [self testCaseWithSelector:selector];
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

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2
{
    NSUInteger length1 = [string1 length];
    NSUInteger length2 = [string2 length];
    
    STAssertTrue(length1 == length2, @"string lengths don't match: was %ld expected %ld \n\nwas:\n%@\n\nexpected:\n%@", length1, length2, string1, string2); 
    
    NSUInteger safeLength = MIN(length1, length2);
    for (NSUInteger n = 0; n < safeLength; ++n)
    {
        UniChar c1 = [string1 characterAtIndex:n];
        UniChar c2 = [string2 characterAtIndex:n];
        STAssertTrue(c1 == c2, @"Comparison failed at character %ld (was 0x%x '%c' expected 0x%x '%c') of:\n\n%@", n, c1, c1, c2, c2, string1);
        if (c1 != c2)
        {
            break; // in theory we could report every character difference, but it could get silly, so we stop after the first failure
        }
    }
}

// --------------------------------------------------------------------------
//! Return a count for any item that supports the count or length methods.
//! Used in various test assert macros.
// --------------------------------------------------------------------------

+ (NSUInteger)genericCount:(id)item
{
	NSUInteger result;
	
	if ([item respondsToSelector:@selector(length)])
	{
		result = [(NSString*)item length]; // NB doesn't have to be a string, the cast is just there to stop xcode complaining about multiple method signatures
	}
	else if ([item respondsToSelector:@selector(count)])
	{
		result = [(NSArray*)item count]; // NB doesn't have to be an array, the cast is kust there to stop xcode complaining about multiple method signatures
	}
	else
	{
		result = 0;
	}
	
	return result;
}


// --------------------------------------------------------------------------
//! Return file path for a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSString*)testBundlePath
{
	// find test bundle in our resources
	char  buffer[PATH_MAX];
	const char* path = getcwd(buffer, PATH_MAX);
	NSString* result = [NSString stringWithFormat:@"%s/Modules/ECCore/Resources/Tests/Test.bundle", path];
	
	return result;
}

// --------------------------------------------------------------------------
//! Return file URL for a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSURL*)testBundleURL
{
	NSURL* url = [NSURL fileURLWithPath:[self testBundlePath]];
	
	return url;
}

// --------------------------------------------------------------------------
//! Return a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSBundle*)testBundle
{
	NSBundle* bundle = [NSBundle bundleWithPath:[self testBundlePath]];
	
	return bundle;
}

@end
