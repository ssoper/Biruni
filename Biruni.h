//
//  Biruni.h
//  Biruni
//
//  Created by Sean Soper on 12/15/10.
//

#import <Foundation/Foundation.h>
  

@interface Biruni : NSObject <NSXMLParserDelegate> {
  NSURL *url;
  NSArray *tagsToParse;
  void (^afterParse)(NSArray *);
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *tagsToParse;
@property (copy) void (^afterParse)(NSArray *);

+ (void) parseWithFeedURL:(NSString *) url
                  andTags:(NSString *) tags
                 andBlock:(void(^)(NSArray *)) block;

@end
