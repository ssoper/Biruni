//
//  BiruniResult.m
//  Biruni
//
//  Created by Sean Soper on 12/20/10.
//  Copyright 2010 Intridea. All rights reserved.
//

#import "BiruniResult.h"


@implementation BiruniResult

@synthesize dict;

- (id) initWithDict:(NSMutableDictionary *) _dict {
  if (self = [super init]) {
    self.dict = _dict;
  }

  return self;
}

- (id) getValue:(NSString*) name {
  return [dict objectForKey: name];
}

- (void) forwardInvocation: (NSInvocation*)invocation {
  NSString *key = NSStringFromSelector([invocation selector]);
  [invocation setArgument: &key atIndex: 2];
  [invocation setSelector: NSSelectorFromString(@"getValue:")];
  return [invocation invokeWithTarget:self];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  if([dict objectForKey: NSStringFromSelector(sel)] != nil) {
    NSMethodSignature* sig;
    sig = [[self class]  
           instanceMethodSignatureForSelector:
           NSSelectorFromString(@"getValue:") ];
    return sig;
  } else {
    return [super methodSignatureForSelector: sel];
  }
}

- (void) dealloc {
  [dict release];

  [super dealloc];
}

@end
