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

- (void) testBasic {
  [Biruni parseData: [self loadTestCase: @"Basic"] tags: @"title,year" block: ^(NSArray *results) {
    STAssertEquals((NSUInteger)2, results.count, @"There should be 2 results but instead there were %u", results.count);
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
