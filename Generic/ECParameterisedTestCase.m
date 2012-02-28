// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECParameterisedTestCase.h"

#import <objc/runtime.h>

@implementation ECParameterisedTestCase

// --------------------------------------------------------------------------
//! Standard keys.
// --------------------------------------------------------------------------

NSString *const DataItems = @"ECTestData";
NSString *const ChildItems = @"ECTestChildren";
NSString *const SuiteExtension = @"testsuite";

@synthesize parameterisedTestName;
@synthesize parameterisedTestDataItem;

// --------------------------------------------------------------------------
//! Make a test case with a given selector and parameter.
// --------------------------------------------------------------------------

+ (id)testCaseWithSelector:(SEL)selector param:(id)param
{
    ECParameterisedTestCase* tc = [self testCaseWithSelector:selector];
    tc.parameterisedTestDataItem = param;
    
    return tc;
}

// --------------------------------------------------------------------------
//! Make a test case with a given selector, parameter and a custom name.
// --------------------------------------------------------------------------

+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name
{
    ECParameterisedTestCase* tc = [self testCaseWithSelector:selector];
    tc.parameterisedTestDataItem = param;
    tc.parameterisedTestName = name;
    
    return tc;
}

// --------------------------------------------------------------------------
//! Return a cleaned up version of the name, as a CamelCase string.
// --------------------------------------------------------------------------

+ (NSString*)cleanedName:(NSString*)name
{
    NSString* result = name;
    NSCharacterSet* separators = [NSCharacterSet whitespaceCharacterSet];
    NSArray* words = [name componentsSeparatedByCharactersInSet:separators];
    if ([words count] > 1)
    {
        NSMutableString* cleaned = [NSMutableString stringWithCapacity:[name length]];
        for (NSString* word in words)
        {
            [cleaned appendString:[word capitalizedString]];
        }
        result = cleaned;
    }

    return result;
}

// --------------------------------------------------------------------------
//! Return the test case's name.
//! If we've overridden the default method name, we return
//! that, otherwise we do the default thing.
// --------------------------------------------------------------------------

- (NSString*)name
{
    NSString* result;
    
    if (self.parameterisedTestName)
    {
        result = [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass([self class]), self.parameterisedTestName];
    }
    else 
    {
        result = [super name];
    }
    
    return result;
}


#pragma mark - Tests

// --------------------------------------------------------------------------
//! Build up data for an item from a folder
// --------------------------------------------------------------------------

+ (NSDictionary*)parameterisedTestDataFromItem:(NSURL*)folder
{
    
    // if there's a testdata.plist here, add values from it
    NSMutableDictionary* result = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    if ([fm fileExistsAtPath:[folder path] isDirectory:&isDirectory] && isDirectory)
    {
        result = [NSMutableDictionary dictionary];
        NSError* error = nil;
        NSArray* itemURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
        for (NSURL* item in itemURLs)
        {
            NSString* fullName = [item lastPathComponent];
            NSString* name = [fullName stringByDeletingPathExtension];
            if ([fullName isEqualToString:@"testdata.plist"])
            {
                NSDictionary* entries = [NSDictionary dictionaryWithContentsOfURL:item];
                [result addEntriesFromDictionary:entries];
            }
            else
            {
                id value = [NSString stringWithContentsOfURL:item encoding:NSUTF8StringEncoding error:&error];
                if (!value)
                {
                    value = item;
                }
                [result setObject:value forKey:name];
            }
        }
    }
    
    return result;
}

// --------------------------------------------------------------------------
//! Recurse through a directory structure building up a dictionary from it.
// --------------------------------------------------------------------------

+ (NSDictionary*)parameterisedTestDataFromFolder:(NSURL*)folder
{
    
    // if there's a testdata.plist here, add values from it
    NSMutableDictionary* result = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    if ([fm fileExistsAtPath:[folder path] isDirectory:&isDirectory] && isDirectory)
    {
        result = [NSMutableDictionary dictionary];
        NSError* error = nil;
        NSArray* itemURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
        NSMutableDictionary* items = [NSMutableDictionary dictionary];
        NSMutableDictionary* children = [NSMutableDictionary dictionary];
        for (NSURL* item in itemURLs)
        {
            NSString* fullName = [item lastPathComponent];
            NSString* name = [fullName stringByDeletingPathExtension];
            NSString* extension = [fullName pathExtension];
            if ([extension isEqualToString:SuiteExtension])
            {
                NSDictionary* itemData = [self parameterisedTestDataFromFolder:item];
                [children setObject:itemData forKey:name];
            }
            else if ([fullName isEqualToString:@"testdata.plist"])
            {
                NSDictionary* entries = [NSDictionary dictionaryWithContentsOfURL:item];
                [result addEntriesFromDictionary:entries];
            }
            else
            {
                [items setObject:[self parameterisedTestDataFromItem:item] forKey:name];
            }
        }
        
        [result setObject:children forKey:ChildItems];
        [result setObject:items forKey:DataItems];
    }

    return result;
}

// --------------------------------------------------------------------------
//! Return a dictionary of test data.
//! By default, we try to load a plist from the test bundle
//! that has the same name as this class, and return that.
// --------------------------------------------------------------------------

+ (NSDictionary*) parameterisedTestData
{
    NSDictionary* result;
    
    NSURL* plist = [[NSBundle bundleForClass:[self class]] URLForResource:NSStringFromClass([self class]) withExtension:@"plist"];
    if (plist)
    {
        result = [NSDictionary dictionaryWithContentsOfURL:plist];
        if (![result objectForKey:DataItems])
        {
            result = [NSDictionary dictionaryWithObject:result forKey:DataItems];
        }
    }
    else 
    {
        NSURL* folder = [[NSBundle bundleForClass:[self class]] URLForResource:NSStringFromClass([self class]) withExtension:SuiteExtension];
        if (folder)
        {
            result = [self parameterisedTestDataFromFolder:folder];
        }
        else 
        {
            result = nil;
        }
    }
    
    return result;
}

+ (SenTestSuite*)suiteForSelector:(SEL)selector name:(NSString*)name data:(NSDictionary*)data
{
    SenTestSuite* subSuite = [[SenTestSuite alloc] initWithName:name];
    NSDictionary* items = [data objectForKey:DataItems];
    for (NSString* testName in items)
    {
        NSString* cleanName = [self cleanedName:testName];
        NSDictionary* testData = [items objectForKey:testName];
        [subSuite addTest:[self testCaseWithSelector:selector param:testData name:cleanName]];
    }

    NSDictionary* children = [data objectForKey:ChildItems];
    for (NSString* childName in children)
    {
        NSDictionary* childData = [children objectForKey:childName];
        SenTestSuite* childSuite = [self suiteForSelector:selector name:childName data:childData];
        [subSuite addTest:childSuite];
    }
    
    return [subSuite autorelease];
}

// --------------------------------------------------------------------------
//! Return the tests.
//! We iterate through our instance methods looking for ones
//! that begin with "parameterisedTest".
//! For each one that we find, we add a sub-suite of tests applying
//! each item of test data in turn.
// --------------------------------------------------------------------------

+ (id) defaultTestSuite
{
    SenTestSuite* result = nil;
    NSDictionary* data = [self parameterisedTestData];
    if (data)
    {
        result = [[SenTestSuite alloc] initWithName:NSStringFromClass(self)];
        unsigned int methodCount;
        Method* methods = class_copyMethodList([self class], &methodCount);
        for (NSUInteger n = 0; n < methodCount; ++n)
        {
            SEL selector = method_getName(methods[n]);
            NSString* name = NSStringFromSelector(selector);
            if ([name rangeOfString:@"parameterisedTest"].location == 0)
            {
                SenTestSuite* subSuite = [self suiteForSelector:selector name:name data:data];
                [result addTest:subSuite];
            }
        }
    }

    return [result autorelease];
}

@end
