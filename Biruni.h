//
//  Biruni.h
//  Biruni
//
//  Created by Sean Soper on 12/15/10.
//

#import <Foundation/Foundation.h>
  

@interface Biruni : NSObject <NSXMLParserDelegate> {
  NSXMLParser *parser;
  NSURL *url;
  NSArray *tagsToParse;
  void (^afterParse)(NSArray *);
}

@property (nonatomic, retain, readonly) NSXMLParser *parser;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *tagsToParse;
@property (copy) void (^afterParse)(NSArray *);

+ (void) parseWithFeedURL:(NSString *) url
                  andTags:(NSArray *) tags
                 andBlock:(void(^)(NSArray *)) block;

@end
