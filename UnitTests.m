//
//  UnitTests.m
//  Biruni
//
//  Copyright (c) 2010 Sean Soper
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UnitTests.h"
#import "Biruni.h"


@interface UnitTests (Private)
- (NSData *) loadTestCase:(NSString *) testCase;
@end


@implementation UnitTests

#pragma mark -
#pragma mark Tests

- (void) testCount {
  [Biruni parseData: [self loadTestCase: @"Basic"] tags: @"title,year" block: ^(NSArray *results) {
    NSUInteger expected = 3;
    STAssertEquals(expected, results.count, @"There should be %u results but instead there were %u", expected, results.count);
  }];
}

- (void) testTitles {
  [Biruni parseData: [self loadTestCase: @"Basic"] tags: @"title,year" block: ^(NSArray *results) {
    NSArray *titles = [NSArray arrayWithObjects: @"Bringing up Baby", @"His Girl Friday", @"Arsenic and Old Lace", nil];
    for (NSUInteger count = 0; count < results.count; count++) {
      STAssertEqualObjects([[results objectAtIndex: count] objectForKey: @"title"],
                           [titles objectAtIndex: count],
                           @"Title should be %@ but is %@",
                           [titles objectAtIndex: count],
                           [[results objectAtIndex: count] objectForKey: @"title"]);
    }
  }];
}

- (void) testCategories {
  [Biruni parseData: [self loadTestCase: @"Basic"] tags: @"title,year,category" block: ^(NSArray *results) {
    NSUInteger expected, actual;
    expected = 2;
    for (id result in results) {
      actual = [[result objectForKey: @"category"] count];
      STAssertEquals(expected, actual, @"There should be %u categories but there are only %u", expected, actual);
    }
  }];
}


#pragma mark -
#pragma mark Private

- (NSData *) loadTestCase:(NSString *) testCase {
  NSString *file = [[NSBundle bundleForClass: [UnitTests class]] pathForResource: testCase ofType: @"xml"];
  NSData *data = [NSData dataWithContentsOfFile: file];
  return data;
}

@end
