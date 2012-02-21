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
//! Does this string begin with another string?
//! Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 beginsWithString:(NSString *)string2
{
	NSRange range = [string1 rangeOfString:string2];
	
	return range.location == 0;
}

// --------------------------------------------------------------------------
//! Does this string end with another string.
//! Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 endsWithString:(NSString *)string2
{
	NSUInteger length = [string2 length];
	BOOL result = length > 0;
	if (result)
	{
		NSUInteger ourLength = [string1 length];
		result = (length <= ourLength);
		if (result)
		{
			NSString* substring = [string1 substringFromIndex:ourLength - length];
			result = [string2 isEqualToString:substring];
		}
	}
	
	return result;
}

// --------------------------------------------------------------------------
//! Does this string contain another string?
//! Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 containsString:(NSString *)string2
{
	NSRange range = [string1 rangeOfString:string2];
	
	return range.location != NSNotFound;
}

// --------------------------------------------------------------------------
//! Return file path for a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSString*)testBundlePath
{
	// find test bundle in our resources
	NSBundle* ourBundle = [NSBundle bundleForClass:[self class]];
	NSString* path = [ourBundle pathForResource:@"Test" ofType:@"bundle"];
	
	return path;
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

