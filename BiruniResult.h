//
//  BiruniResult.h
//  Biruni
//
//  Created by Sean Soper on 12/20/10.
//  Copyright 2010 Intridea. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BiruniResult : NSObject {
  NSDictionary *dict;
}

@property (nonatomic, retain) NSDictionary *dict;

- (id) initWithDict:(NSMutableDictionary *) _dict;
- (id) getValue:(NSString *) name;
- (void) forwardInvocation:(NSInvocation *) invocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL) sel;

@end
