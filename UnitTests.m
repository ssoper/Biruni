//
//  UnitTests.m
//  Biruni
//
//  Created by Sean Soper on 12/19/10.
//  Copyright 2010 Intridea. All rights reserved.
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
    STAssertEquals((NSUInteger)2, results.count, @"There should be 2 results but instead there were %u", results.count);
  }];
}

- (void) testTitles {
  [Biruni parseData: [self loadTestCase: @"Basic"] tags: @"title,year" block: ^(NSArray *results) {
    NSArray *titles = [NSArray arrayWithObjects: @"Bringing up Baby", @"His Girl Friday", @"Arsenic and Old Lace", nil];
    for (NSUInteger count = 0; count < results.count; count++) {
      STAssertEqualObjects([[results objectAtIndex: count] title],
                           [titles objectAtIndex: count],
                           @"Title should be %@ but is %@",
                           [titles objectAtIndex: count],
                           [[results objectAtIndex: count] title]);
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
